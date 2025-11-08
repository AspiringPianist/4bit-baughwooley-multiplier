`timescale 1ns / 1ps

//
// Baugh-Wooley Multiplier based on the provided derivation
// n=4, so inputs are 4-bit and output is 8-bit.
//
//module baugh_wooley_derived (
//    input  signed [3:0] a,
//    input  signed [3:0] b,
//    output signed [7:0] p
//);

//    // Let n = 4. The output width is 2n = 8.
    
//    // -- Term 1: a_{n-1} * b_{n-1} * 2^(2n-2) --
//    // For n=4, this is (a[3] & b[3]) shifted left by 6.
//    wire [7:0] term1 = {1'b0, (a[3] & b[3]), 6'b0};

//    // -- Term 2: Unsigned product of the lower bits --
//    // This is the double summation part: sum(sum(a_i*b_j*2^(i+j))) for i,j < n-1
//    // It's equivalent to the unsigned multiplication of a[2:0] and b[2:0].
//    wire [7:0] term2 = a[2:0] * b[2:0];

//    // -- Term 3: Sum involving inverted partial products with b_{n-1} --
//    // Corresponds to: 2^(n-1) * sum(overline(a_i * b_{n-1}) * 2^i)
//    // For n=4, this is {~p23, ~p13, ~p03} shifted left by 3.
//    // where p_i3 = a[i] & b[3].
//    wire [2:0] sum_a_inv = ~(a[2:0] & {3{b[3]}}); // {~p23, ~p13, ~p03}
//    wire [7:0] term3 = {2'b0, sum_a_inv, 3'b0};

//    // -- Term 4: Sum involving inverted partial products with a_{n-1} --
//    // Corresponds to: 2^(n-1) * sum(overline(b_j * a_{n-1}) * 2^j)
//    // Symmetric to Term 3.
//    wire [2:0] sum_b_inv = ~(b[2:0] & {3{a[3]}}); // {~p32, ~p31, ~p30}
//    wire [7:0] term4 = {2'b0, sum_b_inv, 3'b0};

//    // -- Term 5: The final constant --
//    // This is -2^(2n-1) + 2^n
//    // For n=4, this is -2^7 + 2^4 = -128 + 16 = -112.
//    // In 8-bit 2's complement, -112 is 10010000.
//    wire [7:0] term5 = 8'b10010000;
    
//    // The final product is the sum of all these terms.
//    assign p = term1 + term2 + term3 + term4 + term5;

//endmodule


// Helper module: Standard Full Adder
module full_adder(input a, b, cin, output sum, cout);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// Baugh-Wooley white-cell from diagram (a)
module bw_white_cell (
    input  a_in, b_in, s_in, c_in,
    output a_out, b_out, s_out, c_out
);
    wire pp = a_in & b_in; // Partial product with AND
    
    // Pass-through wires
    assign a_out = a_in;
    assign b_out = b_in;

    full_adder fa (
        .a(pp), 
        .b(s_in), 
        .cin(c_in), 
        .sum(s_out), 
        .cout(c_out)
    );
endmodule

// Baugh-Wooley gray-cell from diagram (b)
module bw_gray_cell (
    input  a_in, b_in, s_in, c_in,
    output a_out, b_out, s_out, c_out
);
    wire pp = ~(a_in & b_in); // Partial product with NAND
    
    // Pass-through wires
    assign a_out = a_in;
    assign b_out = b_in;

    full_adder fa (
        .a(pp), 
        .b(s_in), 
        .cin(c_in), 
        .sum(s_out), 
        .cout(c_out)
    );
endmodule

// -----------------------------------------------------------------------------
// Pipelined Baugh-Wooley 4×4 (row-pipelined, 4 stages total)
// Latency: 4 cycles (row0|row1|row2|row3+final adders)
// Throughput: 1 result / cycle once pipeline is full
// Requires the PE modules you already have in design.v:
//   - full_adder
//   - bw_white_cell  (AND -> FA)
//   - bw_gray_cell   (NAND -> FA) used when (i==3 || j==3) && !(i==3 && j==3)
// -----------------------------------------------------------------------------
module baugh_wooley_4x4_pipe (
    input  wire        clk,
    input  wire        rst,        // sync reset, active high
    input  wire        in_valid,
    input  wire [3:0]  a,
    input  wire [3:0]  b,
    output reg         out_valid,
    output reg  [7:0]  p
);
  // -------------------------
  // Stage 0 (inputs -> Row 0)
  // -------------------------
  reg [3:0] a0, b0; reg v0;
  always @(posedge clk) begin
    if (rst) begin a0<=0; b0<=0; v0<=0; end
    else       begin a0<=a; b0<=b; v0<=in_valid; end
  end

  // Row 0 (i=0): s_in = 0, c_in = 0, gray at j==3
  wire [3:0] s0, c0;
  // j=0..2 white, j=3 gray
  bw_white_cell r0c0 (.a_in(a0[0]), .b_in(b0[0]), .s_in(1'b0), .c_in(1'b0), .a_out(), .b_out(), .s_out(s0[0]), .c_out(c0[0]));
  bw_white_cell r0c1 (.a_in(a0[1]), .b_in(b0[0]), .s_in(1'b0), .c_in(1'b0), .a_out(), .b_out(), .s_out(s0[1]), .c_out(c0[1]));
  bw_white_cell r0c2 (.a_in(a0[2]), .b_in(b0[0]), .s_in(1'b0), .c_in(1'b0), .a_out(), .b_out(), .s_out(s0[2]), .c_out(c0[2]));
  bw_gray_cell  r0c3 (.a_in(a0[3]), .b_in(b0[0]), .s_in(1'b0), .c_in(1'b0), .a_out(), .b_out(), .s_out(s0[3]), .c_out(c0[3]));

  // Register boundary after Row 0
  // Also capture p[0] = s0[0], and pipeline a/b to keep alignment
  reg [3:0] a1, b1; reg v1;
  reg [3:0] c1;     // carries down into next row
  reg [2:0] s0_shifted_for_row1; // s_net[0][j+1] for j=0..2
  reg       p0_lsb; // p[0]
  always @(posedge clk) begin
    if (rst) begin
      a1<=0; b1<=0; v1<=0; c1<=0; s0_shifted_for_row1<=0; p0_lsb<=0;
    end else begin
      a1<=a0; b1<=b0; v1<=v0;
      c1<=c0;                        // c_in for row1 = c0[j]
      s0_shifted_for_row1 <= {s0[3], s0[2], s0[1]}; // s_net[0][1], [0][2], [0][3]
      p0_lsb <= s0[0];               // commit p[0]
    end
  end

  // -------------------------
  // Stage 1 (Row 1, i=1)
  // s_in(j) = (j==3)? 0 : s_net[0][j+1] → from s0_shifted_for_row1
  // c_in(j) = c1[j]
  // Gray at j==3
  // -------------------------
  wire [3:0] s1, c2;
  bw_white_cell r1c0 (.a_in(a1[0]), .b_in(b1[1]), .s_in(s0_shifted_for_row1[0]), .c_in(c1[0]), .a_out(), .b_out(), .s_out(s1[0]), .c_out(c2[0]));
  bw_white_cell r1c1 (.a_in(a1[1]), .b_in(b1[1]), .s_in(s0_shifted_for_row1[1]), .c_in(c1[1]), .a_out(), .b_out(), .s_out(s1[1]), .c_out(c2[1]));
  bw_white_cell r1c2 (.a_in(a1[2]), .b_in(b1[1]), .s_in(s0_shifted_for_row1[2]), .c_in(c1[2]), .a_out(), .b_out(), .s_out(s1[2]), .c_out(c2[2]));
  bw_gray_cell  r1c3 (.a_in(a1[3]), .b_in(b1[1]), .s_in(1'b0),                   .c_in(c1[3]), .a_out(), .b_out(), .s_out(s1[3]), .c_out(c2[3]));

  // Register boundary after Row 1
  // Capture p[1] = s1[0]; prepare s1 shifted for row2 s_in
  reg [3:0] a2, b2; reg v2;
  reg [3:0] c3;
  reg [2:0] s1_shifted_for_row2;
  reg [1:0] p01;
  always @(posedge clk) begin
    if (rst) begin
      a2<=0; b2<=0; v2<=0; c3<=0; s1_shifted_for_row2<=0; p01<=0;
    end else begin
      a2<=a1; b2<=b1; v2<=v1;
      c3<=c2;
      s1_shifted_for_row2 <= {s1[3], s1[2], s1[1]}; // s_net[1][1..3]
      p01 <= {s1[0], p0_lsb};                       // p[1], p[0]
    end
  end

  // -------------------------
  // Stage 2 (Row 2, i=2)
  // s_in(j) = (j==3)? 0 : s_net[1][j+1] → from s1_shifted_for_row2
  // c_in(j) = c3[j]
  // Gray at j==3
  // -------------------------
  wire [3:0] s2, c4;
  bw_white_cell r2c0 (.a_in(a2[0]), .b_in(b2[2]), .s_in(s1_shifted_for_row2[0]), .c_in(c3[0]), .a_out(), .b_out(), .s_out(s2[0]), .c_out(c4[0]));
  bw_white_cell r2c1 (.a_in(a2[1]), .b_in(b2[2]), .s_in(s1_shifted_for_row2[1]), .c_in(c3[1]), .a_out(), .b_out(), .s_out(s2[1]), .c_out(c4[1]));
  bw_white_cell r2c2 (.a_in(a2[2]), .b_in(b2[2]), .s_in(s1_shifted_for_row2[2]), .c_in(c3[2]), .a_out(), .b_out(), .s_out(s2[2]), .c_out(c4[2]));
  bw_gray_cell  r2c3 (.a_in(a2[3]), .b_in(b2[2]), .s_in(1'b0),                   .c_in(c3[3]), .a_out(), .b_out(), .s_out(s2[3]), .c_out(c4[3]));

  // Register boundary after Row 2
  // Capture p[2] = s2[0]; prepare s2 shifted for row3 s_in
  reg [3:0] a3, b3; reg v3;
  reg [3:0] c5;
  reg [2:0] s2_shifted_for_row3;
  reg [2:0] p012;
  always @(posedge clk) begin
    if (rst) begin
      a3<=0; b3<=0; v3<=0; c5<=0; s2_shifted_for_row3<=0; p012<=0;
    end else begin
      a3<=a2; b3<=b2; v3<=v2;
      c5<=c4;
      s2_shifted_for_row3 <= {s2[3], s2[2], s2[1]}; // s_net[2][1..3]
      p012 <= {s2[0], p01};                         // p[2:0]
    end
  end

  // -------------------------
  // Stage 3 (Row 3, i=3) + final adders
  // s_in(j) = (j==3)? 0 : s_net[2][j+1] → from s2_shifted_for_row3
  // c_in(j) = c5[j]
  // Gray at i==3 (entire row), except corner (3,3) which is white in your code.
  // -------------------------
  wire [3:0] s3, c6;
  // j=0..2 gray (i==3), j=3 white (corner not gray)
  bw_gray_cell  r3c0 (.a_in(a3[0]), .b_in(b3[3]), .s_in(s2_shifted_for_row3[0]), .c_in(c5[0]), .a_out(), .b_out(), .s_out(s3[0]), .c_out(c6[0]));
  bw_gray_cell  r3c1 (.a_in(a3[1]), .b_in(b3[3]), .s_in(s2_shifted_for_row3[1]), .c_in(c5[1]), .a_out(), .b_out(), .s_out(s3[1]), .c_out(c6[1]));
  bw_gray_cell  r3c2 (.a_in(a3[2]), .b_in(b3[3]), .s_in(s2_shifted_for_row3[2]), .c_in(c5[2]), .a_out(), .b_out(), .s_out(s3[2]), .c_out(c6[2]));
  bw_white_cell r3c3 (.a_in(a3[3]), .b_in(b3[3]), .s_in(1'b0),                    .c_in(c5[3]), .a_out(), .b_out(), .s_out(s3[3]), .c_out(c6[3]));

  // Final 4 adders exactly as in your design.v,
  // but kept in the SAME stage and then registered to outputs.
  wire [3:0] final_carry_out;
  wire [7:0] p_comb;
  assign p_comb[0] = s0[0];     // committed earlier through p012/p01/p0_lsb path
  assign p_comb[1] = s1[0];
  assign p_comb[2] = s2[0];
  assign p_comb[3] = s3[0];

  wire [3:0] p45x;
  full_adder fa_final_0 (.a(s3[1]),      .b(c6[0]), .cin(1'b1),            .sum(p_comb[4]), .cout(final_carry_out[0]));
  full_adder fa_final_1 (.a(s3[2]),      .b(c6[1]), .cin(final_carry_out[0]), .sum(p_comb[5]), .cout(final_carry_out[1]));
  full_adder fa_final_2 (.a(s3[3]),      .b(c6[2]), .cin(final_carry_out[1]), .sum(p_comb[6]), .cout(final_carry_out[2]));
  full_adder fa_final_3 (.a(1'b1),       .b(c6[3]), .cin(final_carry_out[2]), .sum(p_comb[7]), .cout(final_carry_out[3]));

  // Output register (completes Stage 3)
  always @(posedge clk) begin
    if (rst) begin out_valid<=0; p<=0; end
    else begin out_valid<=v3; p<=p_comb; end
  end
endmodule



// 4x4 Baugh-Wooley Multiplier - UNPIPELINED
//
module baugh_wooley_4x4 (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] p
);
    // -- Internal Wires for Sum and Carry Propagation --
    wire [3:0] s_net [3:0];
    wire [3:0] c_net [3:0];

    // -- Generate the 4x4 Processing Cell Array --
    genvar i, j; // i for rows (b), j for columns (a)
    generate
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin

                // Inputs for the top row of cells are constants from the diagram
                wire s_in_val = (i == 0 || j == 3) ? 1'b0 : s_net[i-1][j+1];
                wire c_in_val;
                // The c_in for the top row is special per the diagram
                if (i == 0) begin
                    // These are the complemented 'a' bits fed in
                  assign c_in_val = 1'b0;
                end else begin
                    assign c_in_val = c_net[i-1][j];
                end
                
                // Instantiate gray cells for the last row/col, but NOT the corner
                if ((i == 3 || j == 3) && !(i == 3 && j == 3)) begin
                    bw_gray_cell gray_cell_inst (
                        .a_in(a[j]), .b_in(b[i]), .s_in(s_in_val), .c_in(c_in_val),
                        .a_out(), .b_out(), // Pass-through ports are not needed
                        .s_out(s_net[i][j]), .c_out(c_net[i][j])
                    );
                end else begin
                    bw_white_cell white_cell_inst (
                        .a_in(a[j]), .b_in(b[i]), .s_in(s_in_val), .c_in(c_in_val),
                        .a_out(), .b_out(), // Pass-through ports are not needed
                        .s_out(s_net[i][j]), .c_out(c_net[i][j])
                    );
                end
            end
        end
    endgenerate

    // -- Final Row of Adders --
    wire [3:0] final_carry_out;
    full_adder fa_final_0 (.a(s_net[3][1]), .b(c_net[3][0]), .cin(1'b1), .sum(p[4]), .cout(final_carry_out[0]));
    full_adder fa_final_1 (.a(s_net[3][2]), .b(c_net[3][1]), .cin(final_carry_out[0]), .sum(p[5]), .cout(final_carry_out[1]));
    full_adder fa_final_2 (.a(s_net[3][3]), .b(c_net[3][2]), .cin(final_carry_out[1]), .sum(p[6]), .cout(final_carry_out[2]));
    // The last FA input 'a' is a constant '1' from the diagram
    full_adder fa_final_3 (.a(1'b1),      .b(c_net[3][3]), .cin(final_carry_out[2]), .sum(p[7]), .cout(final_carry_out[3]));

    // -- Assign Lower Product Bits --
    assign p[0] = s_net[0][0];
    assign p[1] = s_net[1][0];
    assign p[2] = s_net[2][0];
    assign p[3] = s_net[3][0];

endmodule