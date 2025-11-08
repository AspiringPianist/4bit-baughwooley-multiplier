# Comparison of Pipelined and Unpipelined Baugh-Wooley Multiplier (Scroll to end of this for VIO/ILA details)
**Name:** Unnath Chittimalla  
**Roll Number:** IMT2023620  

## Objective
To compare the performance of a **pipelined** 4×4 signed Baugh-Wooley multiplier with its **unpipelined** version implemented on a Xilinx Artix-7 FPGA (xc7a35t-cpg236-1). The focus is on **timing performance, logic delay, routing delay, resource usage, and throughput**.

---

## Summary of Results

| Metric | Unpipelined | Pipelined | Improvement |
|-------|------------|-----------|-------------|
| Worst-Case Slack | +3.844 ns | +4.002 ns | Slight improvement |
| Achieved Clock Period | 6.156 ns | 5.998 ns | Faster clock possible |
| Fmax (Max Frequency) | ~162.4 MHz | ~166.7 MHz | ↑ Increased speed |
| Logic Delay | **1.473 ns** | **0.704 ns** | **↓ Reduced by ~2×** |
| Routing Delay | 4.249 ns | 5.036 ns | Slight increase due to added pipeline registers |
| Logic Depth (Levels) | 5 | **2** | **Significantly reduced** |
| Latency | 1 cycle | **4 cycles** | Higher latency |
| Throughput | 1 output/cycle | **1 output/cycle** | Same (but faster clock) |
| LUT Usage | 1364 | 1370 | ~Same |
| FF Usage | 2300 | 2353 | Slightly higher due to pipeline registers |
| Power | 0.081 W | 0.081 W | No meaningful change |

---

## Analysis

### Logic Delay Reduction
The pipelined design breaks the multiplication logic into multiple stages.  
This **reduces logic depth from 5 levels to 2**, resulting in:
- **Lower logic delay (1.47 ns → 0.70 ns)**
- Higher achievable operating frequency (≈162 MHz → ≈167 MHz)

### Routing Delay
Routing delay slightly increases due to added pipeline registers, but the overall **critical path still improves** because logic is the dominant factor.

### Latency vs Throughput
- **Latency increases** (result ready after 4 cycles instead of 1)
- **Throughput remains 1 result per cycle**, and due to higher Fmax, **overall results per second increase**

---

## Conclusion
The **pipelined multiplier clearly outperforms** the unpipelined version in speed and timing closure.  
The key improvement comes from **reduction in logic delay and logic depth**, demonstrating the effectiveness of pipelining in digital design.  
Resource and power overhead remain **minimal**, making pipelining a beneficial optimization in real hardware.

**Final Verdict:** *Pipelining provides higher performance and throughput with negligible cost.*



# 4-Bit Baugh-Wooley Multiplier (IMT2023620 Unnath Ch)

This project implements a 4-bit signed Baugh-Wooley multiplier on a Xilinx FPGA (tested on a Basys 3 board) using the Vivado Suite. It includes two top modules: one for on-chip debugging with VIO/ILA, and another for physical interaction using DIP switches and LEDs.

[Github Link](https://github.com/AspiringPianist/4bit-baughwooley-multiplier)

---

## Demonstration & Results

Here are the VIO and ILA dashboards monitoring the multiplier on the FPGA, along with key implementation reports.

<table>
  <tr>
    <td align="center"><strong>VIO Dashboard</strong><br><em>Controlling inputs and viewing the product in real-time.</em></td>
    <td align="center"><strong>ILA Waveform</strong><br><em>Capturing signal transitions for timing analysis.</em></td>
  </tr>
  <tr>
    <td><img width="451" alt="VIO Dashboard" src="https://github.com/user-attachments/assets/c9fe8ba1-b303-448a-a0cd-339488480b3d" /></td>
    <td><img width="451" alt="ILA Waveform" src="https://github.com/user-attachments/assets/08363e32-8769-46db-a733-21bf46b4c598" /></td>
  </tr>
  <tr>
    <td align="center"><strong>Timing Summary Report</strong></td>
    <td align="center"><strong>Power Report</strong></td>

  </tr>
  <tr>
    <td><img width="451" alt="Timing Summary Report" src="https://github.com/user-attachments/assets/4eae83cc-8100-46ed-a5d9-5ff37b1f0b62" /></td>
    <td><img width="451" alt="Power Report" src="https://github.com/user-attachments/assets/c6d4ace4-3f45-4342-8250-9133e32f13e6" /></td>
  </tr>
</table>

---

## Setup for VIO & ILA Debugging 🛠️

This guide explains how to configure the project for on-chip debugging using Vivado's VIO and ILA IP cores.

### 1. Source File Hierarchy

First, ensure your project sources are set up correctly. The `top_vio_ila` module should be set as the top-level module for this configuration.

<img width="350" alt="Source File Hierarchy" src="https://github.com/user-attachments/assets/59361478-0564-4b04-b4c6-d36f8b1296bc" />

### 2. IP Core Configuration

You'll need to add and configure two IP cores from the IP Catalog as follows:

| IP Core | Port         | Width | Direction | Purpose                       |
| :------ | :----------- | :---- | :-------- | :---------------------------- |
| **VIO** | `probe_in0`  | 8-bit | Input     | Monitors the 8-bit product `p`  |
|         | `probe_out0` | 4-bit | Output    | Controls the 4-bit input `a`    |
|         | `probe_out1` | 4-bit | Output    | Controls the 4-bit input `b`    |
| **ILA** | `probe0`     | 4-bit | Input     | Captures the signal `a`       |
|         | `probe1`     | 4-bit | Input     | Captures the signal `b`       |
|         | `probe2`     | 8-bit | Input     | Captures the signal `p`       |

### 3. Implementation Flow

1.  **Create IP Cores**: Follow the detailed steps below to generate the VIO and ILA cores.
2.  **Set Top Module**: Right-click `top_vio_ila.v` in the Sources window and select **Set as Top**.
3.  **Configure Constraints**: Open `constraints.xdc` and uncomment the clock constraint for your board. **Only the clock constraint should be active.**
    ```xdc
    # For Basys3 board:
    set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
    create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
    ```
4.  **Run Full Flow**: Run **Synthesis**, **Implementation**, and **Generate Bitstream**.
5.  **Program & Debug**: Open **Hardware Manager**, program the FPGA, and the VIO/ILA dashboards will be available for debugging.

---

## Setup for DIP Switch & LED Usage 💡

If you prefer to use physical switches and LEDs instead of the on-chip debugger:

1.  **Set Top Module**: In the Sources window, right-click `top_dip_led.v` and select **Set as Top**.
2.  **Update Constraints**: Open `constraints.xdc` and ensure the pin assignments for the **DIP switches** (inputs `a` and `b`) and **LEDs** (output `p`) are uncommented. The VIO/ILA clock constraint should be commented out.
3.  **Re-run Flow**: Run **Synthesis**, **Implementation**, and **Generate Bitstream**.
4.  **Program FPGA**: Program the device with the new bitstream. You can now control the multiplier with switches and see the result on the LEDs.

---

## Troubleshooting ❓

-   **VIO/ILA not in Hardware Manager?**
    Ensure `top_vio_ila` was set as the top module *before* you generated the bitstream. Reprogram the device.

-   **Synthesis fails with "vio_0 not found"?**
    The VIO IP was not generated correctly. In the Sources window, right-click `vio_0.xci` → **Generate Output Products**.

-   **Clock constraint errors?**
    Make sure you have uncommented **only one** clock constraint in `constraints.xdc` and that the pin assignment (`W5`, `E3`, etc.) matches your specific FPGA board.

---
