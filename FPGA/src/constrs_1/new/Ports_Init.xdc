#set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 4.0 -name clk -waveform {0.000 2.000} -add [get_ports clk]
#      set_property PACKAGE_PIN R17 [get_ports clk]
     
 #     create_clock -name <clock_name> -period <period> [get_ports <clock port>]
