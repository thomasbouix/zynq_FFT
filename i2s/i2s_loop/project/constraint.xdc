set_property PACKAGE_PIN R16        [get_ports { resetn_0 }]; 
set_property IOSTANDARD LVCMOS33    [get_ports { resetn_0 }];

# system clock
set_property PACKAGE_PIN Y9         [get_ports { clk_in1_0 }];    
set_property IOSTANDARD LVCMOS33    [get_ports { clk_in1_0 }]; 

# PMOD : Analog -> Digital
# mlck7   => JA7  => AB11
# lrck8   => JA8  => AB10
# sclk9   => JA9  => AB9
# sdout10 => JA10 => AA8
# GND11   => JA11 => /
# VCC12   => JA12 => /

set_property PACKAGE_PIN AB11       [get_ports { mclko_0 }];    
set_property IOSTANDARD LVCMOS33    [get_ports { mclko_0 }]; 
set_property PACKAGE_PIN AB10       [get_ports { lrcko_0 }];    
set_property IOSTANDARD LVCMOS33    [get_ports { lrcko_0 }];
set_property PACKAGE_PIN AB9        [get_ports { sclko_0 }];    
set_property IOSTANDARD LVCMOS33    [get_ports { sclko_0 }];
set_property PACKAGE_PIN AA8        [get_ports { dout_0 }];    
set_property IOSTANDARD LVCMOS33    [get_ports { dout_0 }];

# PMOD : Digital -> Analog
# mlck1 => JA1 => Y11
# lrck2 => JA2 => AA11
# sclk3 => JA3 => Y10
# sdin4 => JA4 => AA9
# GND5  => JA5 => /
# VCC6  => JA6 => /

set_property PACKAGE_PIN Y11       [get_ports { mclki_0 }];    
set_property IOSTANDARD LVCMOS33   [get_ports { mclki_0 }]; 
set_property PACKAGE_PIN AA11      [get_ports { lrcki_0 }];    
set_property IOSTANDARD LVCMOS33   [get_ports { lrcki_0 }];
set_property PACKAGE_PIN Y10       [get_ports { sclki_0 }];    
set_property IOSTANDARD LVCMOS33   [get_ports { sclki_0 }];
set_property PACKAGE_PIN AA9       [get_ports { din_0 }];    
set_property IOSTANDARD LVCMOS33   [get_ports { din_0 }];
