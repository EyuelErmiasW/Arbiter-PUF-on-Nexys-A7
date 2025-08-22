# hw/nexys_a7_example.xdc
# Example XDC for Nexys A7. You MUST replace PACKAGE_PIN values with your board's master XDC.
# Reference the Digilent Nexys A7 Master XDC to fill correct pins.
# Clock input (example placeholder):
# set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }]
# create_clock -period 10.000 -name sys_clk [get_ports { clk }]

# Reset and button (example placeholders):
# set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports { rstn }]
# set_property -dict { PACKAGE_PIN C19 IOSTANDARD LVCMOS33 } [get_ports { btn_start }]

# LEDs (example placeholders for 8 leds):
# set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { leds[0] }]
# set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { leds[1] }]
# set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { leds[2] }]
# set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { leds[3] }]
# set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports { leds[4] }]
# set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports { leds[5] }]
# set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports { leds[6] }]
# set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { leds[7] }]

# UART TX pin (example placeholder):
# set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports { uart_tx_o }]
