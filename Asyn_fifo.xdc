## -------------------------------------------------------------------------
## 1. Primary Clocks (Write = 80 MHz / 12.5 ns, Read = 40 MHz / 25.0 ns)
##    2x write-to-read speed ratio emphasizes FULL condition.
## -------------------------------------------------------------------------
create_clock -period 12.500 -name clk_wr [get_ports clk_wr]
create_clock -period 25.000 -name clk_rd [get_ports clk_rd]

## -------------------------------------------------------------------------
## 2. Asynchronous Clock Group (CDC)
## -------------------------------------------------------------------------
set_clock_groups -asynchronous -group [get_clocks clk_wr] -group [get_clocks clk_rd]

## -------------------------------------------------------------------------
## 3. Clock Uncertainty
## -------------------------------------------------------------------------
set_clock_uncertainty -setup 0.250 [get_clocks {clk_wr clk_rd}]
set_clock_uncertainty -hold  0.100 [get_clocks {clk_wr clk_rd}]

## -------------------------------------------------------------------------
## 4. Input / Output Delays (Relaxed FULL output delay on clk_wr)
## -------------------------------------------------------------------------
set_input_delay  -clock clk_wr -max 2.000 [get_ports {wr_en d_in[*]}]
set_input_delay  -clock clk_wr -min 0.500 [get_ports {wr_en d_in[*]}]

set_input_delay  -clock clk_rd -max 2.000 [get_ports rd_en]
set_input_delay  -clock clk_rd -min 0.500 [get_ports rd_en]

set_output_delay -clock clk_wr -max 0.500 [get_ports full]
set_output_delay -clock clk_wr -min 0.000 [get_ports full]

set_output_delay -clock clk_rd -max 2.000 [get_ports {empty d_out[*]}]
set_output_delay -clock clk_rd -min 0.000 [get_ports {empty d_out[*]}]

## -------------------------------------------------------------------------
## 5. Asynchronous Reset False Path
## -------------------------------------------------------------------------
set_false_path -from [get_ports rst]

## -------------------------------------------------------------------------
## 6. CDC Synchronizer Placement Hints (ASYN_REG)
## -------------------------------------------------------------------------
set_property ASYN_REG TRUE [get_cells -hier -filter {NAME =~ "*syncff1_rd*" || NAME =~ "*syncff2_rd*"}]
set_property ASYN_REG TRUE [get_cells -hier -filter {NAME =~ "*syncff1_wr*" || NAME =~ "*syncff2_wr*"}]
