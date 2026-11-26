<img width="604" height="156" alt="image" src="https://github.com/user-attachments/assets/d9aaa882-708d-4aba-a1f4-7e5fce8e83c8" />

<img width="473" height="204" alt="image" src="https://github.com/user-attachments/assets/54fc2e3c-e8ba-439f-a5bd-b9e9da136ec9" />

<img width="419" height="50" alt="image" src="https://github.com/user-attachments/assets/bb87f265-48db-4ad2-9d1a-7d59461760b0" />


# Asynchronous FIFO (`asy_fifo`) — Vivado Implementation Report

## Project & Target Overview

* **Project Name:** `fifo_asynchronous`
* **Top Module:** `asy_fifo`
* **Target Device:** AMD/Xilinx Artix-7 (`xc7a12ticsg325-1L`)
* **Design Language:** Verilog (Vivado Simulator)[cite: 7]

---

## Timing Summary

All user-specified timing constraints are met across Setup, Hold, and Pulse Width checks[cite: 4].

| Metric Type | Slack / Metric | Value | Failing Endpoints | Total Endpoints |
| :--- | :--- | :--- | :--- | :--- |
| **Setup** | Worst Negative Slack (WNS) | `5.762 ns` | `0` | `183` |
| **Setup** | Total Negative Slack (TNS) | `0.000 ns` | `0` | `183` |
| **Hold** | Worst Hold Slack (WHS) | `0.079 ns` | `0` | `183` |
| **Hold** | Total Hold Slack (THS) | `0.000 ns` | `0` | `183` |
| **Pulse Width** | Worst Pulse Width Slack (WPWS) | `9.500 ns` | `0` | `176` |
| **Pulse Width** | Total Pulse Width Negative Slack (TPWS) | `0.000 ns` | `0` | `176`[cite: 4] |

---

## Power Analysis (Implemented Netlist)

Power is estimated from the implemented netlist (`typical` process, `25.0 °C` ambient temperature)[cite: 5].

* **Total On-Chip Power:** `0.062 W`
  * **Dynamic Power:** `0.004 W` (`6%` of total on-chip power)
    * **Clocks:** `0.001 W` (`15%` of dynamic)
    * **Signals:** `<0.001 W` (`12%` of dynamic)
    * **Logic:** `<0.001 W` (`12%` of dynamic)
    * **I/O:** `0.002 W` (`61%` of dynamic)
  * **Device Static Power:** `0.059 W` (`94%` of total on-chip power)
* **Junction Temperature:** `25.3 °C`
* **Thermal Margin:** `74.7 °C` (`14.1 W`)[cite: 5]

---

## Resource Utilization (`asy_fifo`)

| Resource | Used | Available | Utilization (%) |
| :--- | :--- | :--- | :--- |
| **Slice LUTs** | `74` | `8,000` | `0.93%` |
| **LUT as Logic** | `74` | `8,000` | `0.93%` |
| **Slice Registers** | `174` | `16,000` | `1.09%` |
| **Slices** | `46` | `3,650` | `1.26%` |
| **Bonded IOB** | `23` | `150` | `15.33%` |
| **BUFGCTRL** | `2` | `32` | `6.25%`[cite: 6, 7] |

---

## Key Takeaways

* **Timing Closure:** Positive WNS (`5.762 ns`), WHS (`0.079 ns`), and WPWS (`9.500 ns`) confirm clean setup, hold, and clock pulse-width margins with zero failing endpoints[cite: 4].
* **Low Footprint & Power:** The 8-bit wide, 16-entry asynchronous FIFO with dual-clock synchronizers uses under `1.3%` of available slices/LUTs/registers on `xc7a12ticsg325-1L`, with dynamic power dominated by I/O (`61%` of dynamic) and total on-chip power at `0.062 W`[cite: 5, 6, 7].
