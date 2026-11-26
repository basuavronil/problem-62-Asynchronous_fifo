<img width="648" height="158" alt="image" src="https://github.com/user-attachments/assets/2e12bf9e-31bb-4335-8b54-037f3572919c" />

<img width="485" height="208" alt="image" src="https://github.com/user-attachments/assets/08e064be-006e-455e-a2cf-3d1ec5406600" />

<img width="423" height="62" alt="image" src="https://github.com/user-attachments/assets/8147ba1c-1c12-4cb5-aa9f-2dc5a9d9ea30" />

# Asynchronous FIFO (`asy_fifo`) — Vivado Implementation Report (80 MHz Write / 40 MHz Read)

## Project & Run Overview

* **Project Name:** `fifo_asynchronous`
* **Top Module:** `asy_fifo`
* **Target Device:** AMD/Xilinx Artix-7 (`xc7a12ticsg325-1L`)
* **Design Language:** Verilog (Vivado Simulator)
* **Synthesis & Implementation Status:** Complete (2 critical warnings reported in each stage)[cite: 13]

---

## Timing Summary

All user-specified timing constraints are met across Setup, Hold, and Pulse Width checks[cite: 10].

| Metric Type | Slack / Metric | Value | Failing Endpoints | Total Endpoints |
| :--- | :--- | :--- | :--- | :--- |
| **Setup** | Worst Negative Slack (WNS) | `0.728 ns` | `0` | `183` |
| **Setup** | Total Negative Slack (TNS) | `0.000 ns` | `0` | `183` |
| **Hold** | Worst Hold Slack (WHS) | `0.065 ns` | `0` | `183` |
| **Hold** | Total Hold Slack (THS) | `0.000 ns` | `0` | `183` |
| **Pulse Width** | Worst Pulse Width Slack (WPWS) | `5.750 ns` | `0` | `176` |
| **Pulse Width** | Total Pulse Width Negative Slack (TPWS) | `0.000 ns` | `0` | `176`[cite: 10]

---

## Power Analysis (Implemented Netlist)

Power is estimated from the implemented netlist (`typical` process, `25.0 °C` ambient temperature)[cite: 11].

* **Total On-Chip Power:** `0.062 W`
  * **Dynamic Power:** `0.003 W` (`5%` of total on-chip power)
    * **Clocks:** `0.001 W` (`23%` of dynamic)
    * **Signals:** `<0.001 W` (`17%` of dynamic)
    * **Logic:** `<0.001 W` (`13%` of dynamic)
    * **I/O:** `0.001 W` (`47%` of dynamic)
  * **Device Static Power:** `0.059 W` (`95%` of total on-chip power)
* **Junction Temperature:** `25.3 °C`
* **Thermal Margin:** `74.7 °C` (`14.1 W`)[cite: 11]

---

## Resource Utilization (`asy_fifo`)

| Resource | Used | Available | Utilization (%) |
| :--- | :--- | :--- | :--- |
| **Slice LUTs** | `75` | `8,000` | `0.94%` |
| **Slice Registers** | `174` | `16,000` | `1.09%` |
| **Slice** | `49` | `3,650` | `1.34%` |
| **LUT as Logic** | `75` | `8,000` | `0.94%` |
| **Bonded IOB** | `23` | `150` | `15.33%` |
| **BUFGCTRL** | `2` | `32` | `6.25%`[cite: 12]

---

## Key Takeaways

* **Timing Closure:** Positive WNS (`0.728 ns`), WHS (`0.065 ns`), and WPWS (`5.750 ns`) confirm timing closure with zero failing endpoints across all 183 setup/hold endpoints and 176 pulse-width endpoints[cite: 10].
* **Compact Footprint & Low Power:** Uses `75` Slice LUTs (`0.94%`), `174` Slice Registers (`1.09%`), `49` Slices (`1.34%`), and `2` `BUFGCTRL`s (`6.25%`) on `xc7a12ticsg325-1L`, maintaining `0.062 W` total on-chip power and a `74.7 °C` thermal margin[cite: 11, 12].


