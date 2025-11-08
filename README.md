# 4-Bit Signed Baugh-Wooley Multiplier – **Pipelined vs Unpipelined Comparison**

**Author:** *Unnath Chittimalla*  
**Roll Number:** *IMT2023620*  

---

## 🎯 Objective
Compare a **pipelined** and **unpipelined** 4×4 signed Baugh-Wooley multiplier on a **Xilinx Artix-7 FPGA** (xc7a35t-cpg236-1), focusing on:

- Critical Path / Timing Performance  
- Logic Delay vs Routing Delay  
- Latency and Throughput  
- FPGA Resource Utilization  
- On-chip Power Consumption  

---

## ✅ Summary of Results

| Metric | Unpipelined | Pipelined | Improvement |
|-------|------------|-----------|-------------|
| Worst-Case Slack | +3.844 ns | **+4.002 ns** | Slight improvement |
| Achieved Clock Period | 6.156 ns | **5.998 ns** | Faster achievable clock |
| Max Freq (F<sub>max</sub>) | ~162.4 MHz | **~166.7 MHz** | Higher performance |
| **Logic Delay (Critical Path)** | **1.473 ns** | **0.704 ns** | **↓ ~2× reduction** |
| Routing Delay | 4.249 ns | 5.036 ns | Slightly increased (expected) |
| Logic Depth | 5 levels | **2 levels** | **Reduced → faster logic** |
| Latency | 1 cycle | **4 cycles** | Output delayed, but throughput same |
| Throughput | 1 result/cycle | **1 result/cycle** | No loss in throughput |
| LUT Usage | 1364 | 1370 | ~Same |
| FF Usage | 2300 | **2353** | Slight increase due to pipeline registers |
| Power | 0.081 W | 0.081 W | No meaningful change |

**Key Insight:**  
The **pipelined multiplier reduces logic delay and logic depth drastically**, enabling higher operating frequency **without increasing power**.

> **Final Verdict:** *Pipelining provides a clear performance improvement at negligible hardware cost.*

---

## 🔍 Why Pipelining Helps

Without pipelining, the design had **one large combinational chain**, causing high logic delay.

Pipelining splits computation across stages:

- ✔ Shorter logic per stage  
- ✔ Lower logic delay → **faster clock possible**
- ✔ Same throughput (1 output/cycle once filled)
- ⚠ Output is delayed by pipeline latency (4 cycles)

---

# 🖥️ Demonstration & Hardware Verification

The design was tested using **VIO** (virtual input/output) and **ILA** (waveform capture).

<table>
  <tr>
    <td align="center"><strong>VIO Dashboard</strong><br><em>Control inputs (a, b) and observe product (p) in real-time.</em></td>
    <td align="center"><strong>ILA Waveform</strong><br><em>Captured pipelined signal transitions.</em></td>
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

# 🛠️ VIO & ILA Setup (for Debug Build)

| IP Core | Port | Width | Direction | Purpose |
|--------|------|-------|-----------|---------|
| **VIO** | `probe_out0` | 4 | Output | Set input **a** |
|        | `probe_out1` | 4 | Output | Set input **b** |
|        | `probe_in0`  | 8 | Input  | View product **p** |
| **ILA** | `probe0` | 4 | Input | Monitor **a** |
|        | `probe1` | 4 | Input | Monitor **b** |
|        | `probe2` | 8 | Input | Monitor **p** |

To use VIO/ILA:
1. Set `top_vio_ila.v` as **Top Module**
2. Generate Bitstream → Program FPGA → View waveforms in Hardware Manager

---

# 💡 DIP Switch + LED Version (no debugging needed)

To use physical switches:
1. Set `top_dip_led.v` as **Top Module**
2. Ensure switch/LED pin constraints are enabled
3. Generate bitstream & program board

---

# 🚀 GitHub Repository

**Code + Top Modules + Screenshots:**  
https://github.com/AspiringPianist/4bit-baughwooley-multiplier

