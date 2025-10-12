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