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


// 4x4 Baugh-Wooley Multiplier - FINAL CORRECTED VERSION
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