## -------------------------------------------------------------------------
## 1. Primary Clock Constraint (50 MHz = 20.000 ns period)
## -------------------------------------------------------------------------
create_clock -period 20.000 -name clk [get_ports clk]

## -------------------------------------------------------------------------
## 2. Clock Uncertainty (Jitter / Margin)
## -------------------------------------------------------------------------
set_clock_uncertainty -setup 0.250 [get_clocks clk]
set_clock_uncertainty -hold  0.100 [get_clocks clk]

## -------------------------------------------------------------------------
## 3. Input / Output Delays (Relative to 50 MHz clk)
## -------------------------------------------------------------------------
set_input_delay  -clock clk -max 2.000 [get_ports {wr_en rd_en data_in[*]}]
set_input_delay  -clock clk -min 0.500 [get_ports {wr_en rd_en data_in[*]}]

set_output_delay -clock clk -max 2.000 [get_ports {data_out[*] empty full almost_empty almost_full}]
set_output_delay -clock clk -min 0.000 [get_ports {data_out[*] empty full almost_empty almost_full}]

## -------------------------------------------------------------------------
## 4. Reset Timing Constraint
## -------------------------------------------------------------------------
# Asynchronous reset: cut timing to functional data paths so reset assertion/
# deassertion does not create artificial setup/hold failures.
set_false_path -from [get_ports rst]

## -------------------------------------------------------------------------
## 5. Optional Physical Pin & IOSTANDARD Constraints (Uncomment for board)
## -------------------------------------------------------------------------
# set_property IOSTANDARD LVCMOS33 [get_ports {clk rst wr_en rd_en empty full almost_empty almost_full}]
# set_property IOSTANDARD LVCMOS33 [get_ports {data_in[*] data_out[*]}]
# set_property PACKAGE_PIN P15 [get_ports clk]
# set_property PACKAGE_PIN U14 [get_ports empty]
# set_property PACKAGE_PIN T13 [get_ports full]
# set_property PACKAGE_PIN V12 [get_ports almost_empty]
# set_property PACKAGE_PIN V14 [get_ports almost_full]
