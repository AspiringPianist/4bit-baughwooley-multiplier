`timescale 1ns / 1ps

//
// Top Module for Board Implementation
// Method 1: Using DIP Switches as Input and LEDs as Output
//
// Interface:
// - 4 DIP switches for multiplicand 'a' (sw[3:0])
// - 4 DIP switches for multiplier 'b' (sw[7:4])
// - 8 LEDs for product output (led[7:0])
// - Optional: 1 button for reset/clear (not strictly needed for combinational logic)
//

module top_dip_led (
    input  [7:0] sw,      // 8 DIP switches: sw[3:0]=a, sw[7:4]=b
    output [7:0] led      // 8 LEDs for product output
);

    // Extract inputs from switches
    wire [3:0] a = sw[3:0];  // Lower 4 switches for multiplicand
    wire [3:0] b = sw[7:4];  // Upper 4 switches for multiplier
    
    // Product output
    wire [7:0] p;
    
    // Instantiate the Baugh-Wooley multiplier
    baugh_wooley_4x4 multiplier_inst (
        .a(a),
        .b(b),
        .p(p)
    );
    
    // Connect product to LEDs
    assign led = p;

endmodule
