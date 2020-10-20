
set_property PACKAGE_PIN R16 [get_ports { reset_rtl }]; 
set_property IOSTANDARD LVCMOS33 [get_ports { reset_rtl }];
    
set_property PACKAGE_PIN Y9 [get_ports { sys_clock }];    
set_property IOSTANDARD LVCMOS33 [get_ports { sys_clock }]; 

set_property PACKAGE_PIN Y19 [get_ports { ver_sync_0 }];
set_property IOSTANDARD LVCMOS33 [get_ports { ver_sync_0 }];

set_property PACKAGE_PIN AA19 [get_ports { hor_sync_0 }];
set_property IOSTANDARD LVCMOS33 [get_ports { hor_sync_0 }];

set_property PACKAGE_PIN V18  [get_ports { red_0[3] }];        
set_property PACKAGE_PIN V19  [get_ports { red_0[2] }];        
set_property PACKAGE_PIN U20  [get_ports { red_0[1] }];        
set_property PACKAGE_PIN V20  [get_ports { red_0[0] }];        
set_property IOSTANDARD LVCMOS33 [get_ports { red_* }];

set_property PACKAGE_PIN AA21 [get_ports { green_0[3] }];        
set_property PACKAGE_PIN AB21 [get_ports { green_0[2] }];        
set_property PACKAGE_PIN AA22 [get_ports { green_0[1] }];        
set_property PACKAGE_PIN AB22 [get_ports { green_0[0] }];        
set_property IOSTANDARD LVCMOS33 [get_ports { green_* }];

set_property PACKAGE_PIN AB19 [get_ports { blue_0[3] }];        
set_property PACKAGE_PIN AB20 [get_ports { blue_0[2] }];       
set_property PACKAGE_PIN Y20  [get_ports { blue_0[1] }];       
set_property PACKAGE_PIN Y21  [get_ports { blue_0[0] }];       
set_property IOSTANDARD LVCMOS33 [get_ports { blue_* }];




