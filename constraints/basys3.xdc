# Clock
set_property PACKAGE_PIN W5  [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 [get_ports clk]

# Reset (BTNC)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# LEDs
set_property PACKAGE_PIN U16 [get_ports {led_detection[0]}]
set_property PACKAGE_PIN E19 [get_ports {led_detection[1]}]
set_property PACKAGE_PIN U19 [get_ports {led_detection[2]}]
set_property PACKAGE_PIN V19 [get_ports {led_detection[3]}]
set_property PACKAGE_PIN W18 [get_ports {led_detection[4]}]
set_property PACKAGE_PIN U15 [get_ports {led_detection[5]}]
set_property PACKAGE_PIN U14 [get_ports {led_detection[6]}]
set_property PACKAGE_PIN V14 [get_ports {led_detection[7]}]
set_property PACKAGE_PIN V13 [get_ports {led_detection[8]}]
set_property PACKAGE_PIN V3  [get_ports {led_detection[9]}]
set_property PACKAGE_PIN W3  [get_ports {led_detection[10]}]
set_property PACKAGE_PIN U3  [get_ports {led_detection[11]}]
set_property PACKAGE_PIN P3  [get_ports {led_detection[12]}]
set_property PACKAGE_PIN N3  [get_ports {led_detection[13]}]
set_property PACKAGE_PIN P1  [get_ports {led_detection[14]}]
set_property PACKAGE_PIN L1  [get_ports {led_detection[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_detection[*]}]

# Voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
