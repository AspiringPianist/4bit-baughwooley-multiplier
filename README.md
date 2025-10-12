# 4-Bit Baugh-Wooley Multiplier

This project implements a 4-bit signed Baugh-Wooley multiplier on a Xilinx FPGA (tested on a Basys 3 board) using the Vivado Suite. Debugging is facilitated by using the VIO (Virtual Input/Output) and ILA (Integrated Logic Analyzer) IP cores.

---

## VIO and ILA Setup Guide 🛠️

This guide explains how to manually create and configure the VIO and ILA IP cores required for debugging the multiplier directly on the FPGA.

### How Sources should be setup

<img width="471" height="743" alt="image" src="https://github.com/user-attachments/assets/59361478-0564-4b04-b4c6-d36f8b1296bc" />


### Quick Reference: IP Configuration

| IP Core | Port         | Width | Direction | Purpose                     |
| :------ | :----------- | :---- | :-------- | :-------------------------- |
| **VIO** | `probe_in0`  | 8-bit | Input     | Monitors product `p`        |
|         | `probe_out0` | 4-bit | Output    | Controls multiplier input `a` |
|         | `probe_out1` | 4-bit | Output    | Controls multiplier input `b` |
| **ILA** | `probe0`     | 4-bit | Input     | Monitors signal `a`         |
|         | `probe1`     | 4-bit | Input     | Monitors signal `b`         |
|         | `probe2`     | 8-bit | Input     | Monitors signal `p`         |

---

## Screenshots of VIO and ILA in Action

Here are the VIO and ILA dashboards monitoring the multiplier on the FPGA.

*VIO Dashboard controlling inputs and showing the resulting product:*
<img width="451" height="256" alt="VIO Dashboard" src="https://github.com/user-attachments/assets/c9fe8ba1-b303-448a-a0cd-339488480b3d" />

*ILA Waveform showing signal transitions over time:*
<img width="1091" height="692" alt="ILA Waveform" src="https://github.com/user-attachments/assets/08363e32-8769-46db-a733-21bf46b4c598" />

*Power Analysis (Reports -> Timing -> Report Timing Summary):*
<img width="1056" height="440" alt="image" src="https://github.com/user-attachments/assets/c6d4ace4-3f45-4342-8250-9133e32f13e6" />

*Timing Analysis Report (Reports -> Power):*
<img width="654" height="1034" alt="image" src="https://github.com/user-attachments/assets/1d313fcb-1b03-44f4-b7a4-1ea5e1417b72" />


---

## Detailed Manual Setup Instructions

### Prerequisites

1.  Open the Baugh-Wooley project in Vivado (`baugh_wooley.xpr`).
2.  Ensure all source files are loaded:
    * **Design Sources**: `design.v`, `top_dip_led.v`, `top_vio_ila.v`
    * **Simulation Sources**: `testbench.v`
    * **Constraints**: `constraints.xdc`

### PART 1: Create VIO (Virtual Input/Output) IP Core 🕵️‍♂️

**Purpose**: VIO allows you to control inputs (`a`, `b`) and monitor the output (`p`) from the Vivado Hardware Manager without physical switches.

1.  **Open IP Catalog**: In the Vivado main window, click on **IP Catalog** in the left panel (or go to `Window` → `IP Catalog`).
2.  **Find VIO IP**: In the IP Catalog search box, type "**VIO**" and double-click on **VIO (Virtual Input/Output)**.
3.  **Configure VIO**:
    * **Component Name**: `vio_0`
    * **PROBE\_IN Ports (Inputs TO VIO)**: Set **Input Probe Count** to `1` and **PROBE\_IN0 Port Width** to `8` (for the 8-bit product `p`).
    * **PROBE\_OUT Ports (Outputs FROM VIO)**: Set **Output Probe Count** to `2`.
        * **PROBE\_OUT0 Port Width**: `4` (for the 4-bit input `a`).
        * **PROBE\_OUT1 Port Width**: `4` (for the 4-bit input `b`).
4.  **Generate VIO IP**: Click **OK**, then click **Generate**.

### PART 2: Create ILA (Integrated Logic Analyzer) IP Core 📈

**Purpose**: ILA captures signal waveforms in real-time for debugging and timing analysis.

1.  **Open IP Catalog** and search for "**ILA**". Double-click on **ILA (Integrated Logic Analyzer)**.
2.  **Configure ILA**:
    * **Component Name**: `ila_0`
    * **Number of Probes**: `3` (to monitor `a`, `b`, and `p`).
    * **Sample Data Depth**: `1024` (can be increased for longer captures).
3.  **Configure ILA Probe Ports**:
    * **PROBE0 Width**: `4` bits (Monitors `a`).
    * **PROBE1 Width**: `4` bits (Monitors `b`).
    * **PROBE2 Width**: `8` bits (Monitors `p`).
4.  **Generate ILA IP**: Click **OK**, then **Generate**.

### PART 3: Set Top Module and Constraints ⚙️

1.  **Set `top_vio_ila` as Top Module**: In the **Sources** window, right-click on `top_vio_ila.v` and select **Set as Top**.
2.  **Configure Clock Constraints**: Open `constraints.xdc` and uncomment the clock constraint for your board. **Only uncomment ONE set!**

    * **For Basys3 board:**
        ```xdc
        set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
        create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
        ```
    * Save the file.

### PART 4: Synthesize, Implement, and Generate Bitstream

1.  **Run Synthesis**: In the Flow Navigator, click **Run Synthesis**.
2.  **Run Implementation**: Click **Run Implementation**.
3.  **Generate Bitstream**: Click **Generate Bitstream**.

### PART 5: Program FPGA and Debug

1.  **Connect and Program FPGA**: Open **Hardware Manager**, auto-connect to your board, and program the device with the generated bitstream.
2.  **Test with VIO**: The **VIO Probes** dashboard will appear. Set values for `probe_out0` (`a`) and `probe_out1` (`b`) and observe the result in `probe_in0` (`p`).
3.  **Capture with ILA**: In the **ILA** dashboard, click the **Run Trigger** button (▶) to capture waveforms and see signal transitions.

---

## Troubleshooting ❓

-   **VIO/ILA not in Hardware Manager?** Ensure `top_vio_ila` was set as top before generating the bitstream. Reprogram the device.
-   **Synthesis fails with "vio_0 not found"?** The VIO IP was not generated correctly. In the Sources window, right-click `vio_0.xci` → **Generate Output Products**.
-   **Clock constraint errors?** Ensure you uncommented **only one** clock constraint in `constraints.xdc` and that it matches your board.

---
