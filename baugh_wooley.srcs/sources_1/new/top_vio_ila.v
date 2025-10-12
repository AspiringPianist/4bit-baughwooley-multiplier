`timescale 1ns / 1ps

//
// Top Module for Board Implementation
// Method 2: Using VIO (Virtual Input/Output) and ILA (Integrated Logic Analyzer)
//
// This module uses Xilinx Debug IPs for verification and debugging:
// - VIO: Provides virtual inputs (a, b) AND monitors output (p)
// - ILA: Captures all signals in real-time for waveform debugging
//
// NOTE: Before synthesis, you must create the following IP cores in Vivado:
// 1. VIO IP: 
//    - 2 output probes: probe_out0 (4-bit) for 'a', probe_out1 (4-bit) for 'b'
//    - 1 input probe: probe_in0 (8-bit) for 'p' (to monitor the product)
// 2. ILA IP:
//    - 3 probes: probe0 (4-bit for 'a'), probe1 (4-bit for 'b'), probe2 (8-bit for 'p')
//    - Sample at clock edge
//    - Set appropriate capture depth (e.g., 1024 samples)
//

module top_vio_ila (
    input clk           // System clock (typically 100 MHz on most Xilinx boards)
);

    // Signals for multiplier inputs and output
    wire [3:0] a;
    wire [3:0] b;
    wire [7:0] p;
    
    // Instantiate the Baugh-Wooley multiplier
    baugh_wooley_4x4 multiplier_inst (
        .a(a),
        .b(b),
        .p(p)
    );
    
    // Instantiate VIO (Virtual Input/Output) IP
    // VIO outputs (probe_out): Control inputs to multiplier from Hardware Manager
    // VIO inputs (probe_in): Monitor outputs from multiplier in Hardware Manager
    vio_0 vio_inst (
        .clk(clk),
        .probe_out0(a),     // 4-bit output: Controls multiplicand 'a'
        .probe_out1(b),     // 4-bit output: Controls multiplier 'b'
        .probe_in0(p)       // 8-bit input: Monitors product 'p' (you can see result in VIO dashboard!)
    );
    
    // Instantiate ILA (Integrated Logic Analyzer) IP
    // ILA captures signals in real-time for debugging with waveforms
    ila_0 ila_inst (
        .clk(clk),
        .probe0(a),         // 4-bit probe for input 'a'
        .probe1(b),         // 4-bit probe for input 'b'
        .probe2(p)          // 8-bit probe for product 'p'
    );

endmodule


//
// Instructions for creating VIO and ILA IP cores in Vivado:
//
// 1. VIO IP Creation:
//    a. In Vivado, go to: IP Catalog -> Debug & Verification -> Debug -> VIO
//    b. Configure VIO:
//       - Component Name: vio_0
//       - General Options:
//         * Input Probe Count: 1 (to MONITOR the product output 'p')
//         * Output Probe Count: 2 (to CONTROL the inputs 'a' and 'b')
//       - Probe Port Widths:
//         * PROBE_IN0 Port Width: 8 (for monitoring product 'p')
//         * PROBE_OUT0 Port Width: 4 (for controlling 'a')
//         * PROBE_OUT1 Port Width: 4 (for controlling 'b')
//    c. Generate the IP
//
// 2. ILA IP Creation:
//    a. In Vivado, go to: IP Catalog -> Debug & Verification -> Debug -> ILA
//    b. Configure ILA:
//       - Component Name: ila_0
//       - Number of Probes: 3
//       - Probe Port Widths:
//         * PROBE0: 4 bits (for signal 'a')
//         * PROBE1: 4 bits (for signal 'b')
//         * PROBE2: 8 bits (for signal 'p')
//       - Sample Data Depth: 1024 (or as needed)
//       - Capture Control: Basic
//    c. Generate the IP
//
// 3. After synthesis and implementation:
//    a. Generate bitstream
//    b. Program the FPGA
//    c. Open Hardware Manager
//    d. VIO Dashboard:
//       - Set probe_out0 (a) and probe_out1 (b) to control inputs
//       - View probe_in0 (p) to see the multiplication result instantly!
//    e. ILA Dashboard:
//       - Capture waveforms to see how signals change over time
//       - Set triggers to capture specific events
//
// Workflow:
// VIO: Real-time control and monitoring (set a, b → instantly see p)
// ILA: Waveform capture for detailed timing analysis
//
