##
## Constraints for 4x4 Baugh-Wooley Multiplier
## Two implementation methods:
## 1. DIP Switches and LEDs (top_dip_led)
## 2. VIO and ILA (top_vio_ila)
##
## NOTE: Uncomment the appropriate section based on your board and implementation method
##       Pin locations are examples for common Xilinx boards - adjust for your specific board!
##

################################################################################
## Clock Signal - Required for VIO/ILA implementation (top_vio_ila)
################################################################################
## Uncomment for Basys3, Nexys A7 (100MHz clock on pin W5)
 set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
 create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Uncomment for Arty A7 (100MHz clock on pin E3)
# set_property -dict { PACKAGE_PIN E3   IOSTANDARD LVCMOS33 } [get_ports clk]
# create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Uncomment for ZedBoard (100MHz clock on pin Y9)
# set_property -dict { PACKAGE_PIN Y9   IOSTANDARD LVCMOS33 } [get_ports clk]
# create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


################################################################################
## Method 1: DIP Switches and LEDs Implementation (top_dip_led)
################################################################################

## DIP Switches (8 switches total: sw[7:0])
## sw[3:0] = multiplicand 'a'
## sw[7:4] = multiplier 'b'

## For Basys3 Board
# set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
# set_property -dict { PACKAGE_PIN V16  IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
# set_property -dict { PACKAGE_PIN W16  IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
# set_property -dict { PACKAGE_PIN W17  IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
# set_property -dict { PACKAGE_PIN W15  IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
# set_property -dict { PACKAGE_PIN V15  IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
# set_property -dict { PACKAGE_PIN W14  IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
# set_property -dict { PACKAGE_PIN W13  IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]

## For Nexys A7 Board
# set_property -dict { PACKAGE_PIN J15  IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
# set_property -dict { PACKAGE_PIN L16  IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
# set_property -dict { PACKAGE_PIN M13  IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
# set_property -dict { PACKAGE_PIN R15  IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
# set_property -dict { PACKAGE_PIN R17  IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
# set_property -dict { PACKAGE_PIN T18  IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
# set_property -dict { PACKAGE_PIN U18  IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
# set_property -dict { PACKAGE_PIN R13  IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]

## For Arty A7 Board
# set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
# set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
# set_property -dict { PACKAGE_PIN C10  IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
# set_property -dict { PACKAGE_PIN A10  IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]


## LEDs (8 LEDs for product output: led[7:0])

## For Basys3 Board
# set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
# set_property -dict { PACKAGE_PIN E19  IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
# set_property -dict { PACKAGE_PIN U19  IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
# set_property -dict { PACKAGE_PIN V19  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
# set_property -dict { PACKAGE_PIN W18  IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
# set_property -dict { PACKAGE_PIN U15  IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
# set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
# set_property -dict { PACKAGE_PIN V14  IOSTANDARD LVCMOS33 } [get_ports {led[7]}]

## For Nexys A7 Board
# set_property -dict { PACKAGE_PIN H17  IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
# set_property -dict { PACKAGE_PIN K15  IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
# set_property -dict { PACKAGE_PIN J13  IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
# set_property -dict { PACKAGE_PIN N14  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
# set_property -dict { PACKAGE_PIN R18  IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
# set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
# set_property -dict { PACKAGE_PIN U17  IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
# set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {led[7]}]

## For Arty A7 Board
# set_property -dict { PACKAGE_PIN H5   IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
# set_property -dict { PACKAGE_PIN J5   IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
# set_property -dict { PACKAGE_PIN T9   IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
# set_property -dict { PACKAGE_PIN T10  IOSTANDARD LVCMOS33 } [get_ports {led[3]}]


################################################################################
## Timing Constraints
################################################################################

## For combinational logic (DIP switch implementation), no specific timing needed
## The multiplier is purely combinational, so outputs change based on inputs

## For VIO/ILA implementation, ensure proper timing closure
## These constraints help achieve timing closure for debug IP
 set_max_delay -from [all_inputs] -to [all_outputs] 20.0
 set_input_delay -clock sys_clk_pin -min 0.0 [all_inputs]
 set_input_delay -clock sys_clk_pin -max 5.0 [all_inputs]
 set_output_delay -clock sys_clk_pin -min 0.0 [all_outputs]
 set_output_delay -clock sys_clk_pin -max 5.0 [all_outputs]


################################################################################
## Power Analysis Constraints
################################################################################

## Set switching activity for power estimation
## Uncomment these for more accurate power analysis
# set_switching_activity -default_static_probability 0.5
# set_switching_activity -default_toggle_rate 10.0


################################################################################
## Additional Constraints for Optimization
################################################################################

## Prevent optimization of debug signals
# set_property DONT_TOUCH true [get_cells multiplier_inst]

## Configuration mode and settings
# set_property CONFIG_MODE SPIx4 [current_design]
# set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
# set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
# set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]


################################################################################
## Usage Instructions
################################################################################
##
## For Method 1 (DIP Switches and LEDs):
## 1. Set top module to: top_dip_led
## 2. Uncomment the switch and LED pin constraints for your board
## 3. No clock constraints needed (purely combinational)
## 4. Synthesize, implement, and generate bitstream
## 5. Program the board
## 6. Use DIP switches to set inputs, observe LEDs for outputs
##
## For Method 2 (VIO and ILA):
## 1. Create VIO IP with 2 output probes (4-bit each)
## 2. Create ILA IP with 3 probes (4-bit, 4-bit, 8-bit)
## 3. Set top module to: top_vio_ila
## 4. Uncomment the clock pin constraint for your board
## 5. Synthesize, implement, and generate bitstream
## 6. Program the board
## 7. Open Hardware Manager
## 8. Use VIO dashboard to control inputs
## 9. Use ILA dashboard to observe and capture waveforms
##
## Power and Timing Analysis:
## 1. After implementation, check Timing Summary report
## 2. Check Power Analysis report for power consumption
## 3. Note worst negative slack (WNS) and total power
##
################################################################################
