`timescale 1ns / 1ps
module top_vio_ila_unpipe (
    input clk
);
    wire [3:0] a;
    wire [3:0] b;
    wire [7:0] p;
    wire out_valid = 1'b1;   // no pipeline = always valid

    // Your original, combinational array
    baugh_wooley_4x4 uut (
        .a(a),
        .b(b),
        .p(p)
    );

    // Reuse SAME VIO
    vio_0 vio_inst (
        .clk(clk),
        .probe_out0(a),
        .probe_out1(b),
        .probe_in0(p)
    );

    // Reuse SAME ILA (probe3 is constant 1 here)
    ila_0 ila_inst (
        .clk(clk),
        .probe0(a),
        .probe1(b),
        .probe2(p),
        .probe3(out_valid)
    );
endmodule
