# Asynchronous FIFO Architecture & Clock Domain Crossing (CDC)

## Overview
An **Asynchronous FIFO (First-In, First-Out)** buffer is used to safely transfer data between two independent clock domains (`wr_clk` and `rd_clk`) that have no fixed phase or frequency relationship. Because signals cross between asynchronous clock domains, proper Clock Domain Crossing (CDC) techniques are mandatory to prevent metastability, data corruption, and false flag assertions (`full` / `empty`).

---

## Key Components

1. **Dual-Port Memory (RAM):** Stores the data written in the write clock domain and read in the read clock domain.
2. **Write Control Logic (`wr_clk` domain):** Manages the binary write pointer, converts it to Gray code, and generates the `full` flag.
3. **Read Control Logic (`rd_clk` domain):** Manages the binary read pointer, converts it to Gray code, and generates the `empty` flag.
4. **CDC Synchronizers:** Safely pass control signals and pointers between the `wr_clk` and `rd_clk` domains.

---

## Clock Domain Crossing (CDC) Strategy

To ensure reliable operation across asynchronous clock boundaries, the design separates single-bit control signals from multi-bit pointer buses, applying the appropriate synchronization technique to each.

### 1. Single-Bit CDC: 2-Flip-Flop (2-FF) Synchronizer
* **Application:** Used for single-bit control signals (e.g., asynchronous reset release, single-bit enable/status flags) or individual bits of a Gray-coded bus.
* **Mechanism:** 
  * The single-bit signal is passed through two back-to-back flip-flops clocked by the destination clock domain.
  * The first flip-flop samples the asynchronous input and may enter a metastable state if setup/hold times are violated.
  * The second flip-flop allows a full clock cycle for the metastable state to resolve to a valid logic level (`0` or `1`) before the signal is used by downstream logic.
* **Why it works:** For a single bit, there is no risk of multi-bit skew; the signal simply arrives either on the current clock edge or one cycle later, both of which are functionally safe for control handshakes.

### 2. Multi-Bit CDC: Gray Code Pointers + 2-FF Synchronizers
* **Application:** Used for multi-bit read (`rd_ptr`) and write (`wr_ptr`) address pointers crossing between clock domains to calculate `full` and `empty` conditions.
* **Why Binary Pointers Fail:** 
  * In standard binary counting, multiple bits can transition simultaneously (e.g., `0111` $\rightarrow$ `1000`).
  * Due to routing delays and clock skew across bits, a 2-FF synchronizer on each bit might sample some bits before the transition and others after, resulting in a corrupted intermediate value (e.g., `1111` or `0000`) and causing false `full`/`empty` flags.
* **Mechanism:**
  * **Binary-to-Gray Conversion:** Before crossing the clock domain, the binary pointer is converted into a **Gray-coded pointer**, where consecutive values differ by **only one bit**.
  * **Synchronization:** Because only one bit changes per increment, a multi-bit Gray pointer behaves like a single-bit transition at any given clock edge. Each bit of the Gray pointer is passed through a standard 2-FF synchronizer into the opposite clock domain.
  * **Outcome:** If a setup/hold violation occurs during sampling, the destination domain will resolve to either the previous valid pointer value or the new valid pointer value—never a corrupted intermediate state.

---

## Pointer Synchronization Flow

```text
  [ Write Clock Domain (wr_clk) ]                  [ Read Clock Domain (rd_clk) ]
  -------------------------------                  ------------------------------
  Binary Write Ptr (wr_bin)                        Binary Read Ptr (rd_bin)
         |                                                |
         v                                                v
  Binary-to-Gray Converter                         Binary-to-Gray Converter
         |                                                |
         v                                                v
  Gray Write Ptr (wr_gray)                         Gray Read Ptr (rd_gray)
         |                                                |
         +---------> [ 2-FF Sync (rd_clk) ] ------------->+---> Used for Empty Logic
                                                          |
  Used for Full Logic <---+--- [ 2-FF Sync (wr_clk) ] <---+
```

---

## Summary of Flag Generation Logic

* **Empty Flag (`rd_clk` domain):** Asserted when the synchronized write Gray pointer equals the local read Gray pointer:
  $$\text{empty} = (\text{rd\_gray\_next} == \text{wr\_gray\_sync})$$
* **Full Flag (`wr_clk` domain):** Asserted when the local write Gray pointer matches the synchronized read Gray pointer, with the top two Most Significant Bits (MSBs) inverted (indicating the write pointer has wrapped around one full cycle ahead of the read pointer):
  $$\text{full} = (\text{wr\_gray\_next} == \{\sim\text{rd\_gray\_sync}[N:N-1], \text{rd\_gray\_sync}[N-2:0]\})$$
