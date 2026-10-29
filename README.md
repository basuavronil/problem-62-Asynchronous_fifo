# Asynchronous FIFO

This project implements an **Asynchronous FIFO (First-In First-Out) buffer in Verilog/SystemVerilog**. An asynchronous FIFO is used to safely transfer data between **two different clock domains**, where the write and read operations are driven by separate clocks.

assign full  = (grey_wr == {~sync_rd[4:3], sync_rd[2:0]}); // overflow if written while full
assign empty = (grey_rd == wr_sync2);                      // underflow if read while empty
// 5-bit Gray pointers: 4 address bits + 1 wrap bit

## 📌 Overview
An **Asynchronous FIFO** allows data to be written using one clock (`wr_clk`) and read using another clock (`rd_clk`). This makes it very useful in systems where different modules operate at **different clock frequencies**. The FIFO ensures that data is transferred reliably without corruption.

## ⚙️ Features
- Separate **write clock and read clock**
- FIFO-based data ordering (First-In First-Out)
- Safe **Clock Domain Crossing (CDC)**
- Full and Empty flag generation
- Metastability mitigation using synchronizers
- Gray code pointer synchronization

## 🏗️ Architecture
The Asynchronous FIFO consists of the following main components:

- **Memory Array** → Stores the incoming data.
- **Write Pointer** → Points to the location where the next data will be written.
- **Read Pointer** → Points to the location from which data will be read.
- **Pointer Synchronizers** → Safely transfer pointers between clock domains.
- **Control Logic** → Generates **Full** and **Empty** flags.

## 🔄 Solving Clock Domain Crossing (CDC)

Since the **write and read sides operate on different clocks**, directly transferring signals between these domains can lead to **Clock Domain Crossing (CDC) issues**. If a signal is sampled while it is changing, the receiving flip-flop may enter an unstable state known as **metastability**.

To prevent this, the design uses **two-flip-flop synchronizers**.

### 🛠️ Two-Flip-Flop Synchronizer
When a pointer crosses from one clock domain to another, it passes through **two sequential flip-flops** in the receiving clock domain.

```
Pointer → FF1 → FF2 → Safe Signal
```

- **FF1** may become metastable when sampling the incoming signal.
- **FF2** provides an extra clock cycle for the signal to settle to a stable value.

This significantly reduces the probability of metastability affecting the system.

## 🔁 Gray Code Pointer Synchronization
The read and write pointers are converted to **Gray code** before crossing clock domains. In Gray code, **only one bit changes at a time**, which reduces the chances of incorrect pointer sampling during synchronization.

## 📂 Project Structure

```
.
├── fifo.v      # Asynchronous FIFO design module
├── tb.sv       # Testbench for simulation
├── README.md   # Project documentation
```

## ▶️ Simulation
The design can be simulated using common **Verilog/SystemVerilog simulation tools**, such as:

- ModelSim
- Vivado Simulator
- Icarus Verilog

The testbench verifies correct FIFO behavior including **write, read, full, and empty conditions**.

## 🚀 Applications
Asynchronous FIFOs are widely used in:

- Clock domain crossing interfaces
- High-speed communication systems
- FPGA and ASIC designs
- Data buffering between modules with different clocks

## 👨‍💻 Author
Avronil
