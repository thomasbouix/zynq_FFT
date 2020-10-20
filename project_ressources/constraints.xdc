###
set_property -dict { PACKAGE_PIN Y9 IOSTANDARD LVCMOS33 } [get_ports { reset_rtl }];     # PLL
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports { sys_clock }];     # boutton

### VGA
set_property -dict { PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 } [get_ports { ver_sync_0 }];     # commentaire
set_property -dict { PACKAGE_PIN AA19 IOSTANDARD LVCMOS33 } [get_ports { hor_sync_0 }];   # commentaire

set_property -dict { PACKAGE_PIN V18 IOSTANDARD LVCMOS33 } [get_ports { red_0[0] }];       # commentaire
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports { red_0[1] }];       # commentaire
set_property -dict { PACKAGE_PIN U20 IOSTANDARD LVCMOS33 } [get_ports { red_0[2] }];       # commentaire
set_property -dict { PACKAGE_PIN V20 IOSTANDARD LVCMOS33 } [get_ports { red_0[3] }];       # commentaire

set_property -dict { PACKAGE_PIN AA21 IOSTANDARD LVCMOS33 } [get_ports { green_0[0] }];       # commentaire
set_property -dict { PACKAGE_PIN AB21 IOSTANDARD LVCMOS33 } [get_ports { green_0[1] }];       # commentaire
set_property -dict { PACKAGE_PIN AA22 IOSTANDARD LVCMOS33 } [get_ports { green_0[2] }];       # commentaire
set_property -dict { PACKAGE_PIN AB22 IOSTANDARD LVCMOS33 } [get_ports { green_0[3] }];       # commentaire

set_property -dict { PACKAGE_PIN AB19 IOSTANDARD LVCMOS33 } [get_ports { blue_0[0] }];       # commentaire
set_property -dict { PACKAGE_PIN AB20 IOSTANDARD LVCMOS33 } [get_ports { blue_0[1] }];       # commentaire
set_property -dict { PACKAGE_PIN Y20 IOSTANDARD LVCMOS33 } [get_ports { blue_0[2] }];       # commentaire
set_property -dict { PACKAGE_PIN Y21 IOSTANDARD LVCMOS33 } [get_ports { blue_0[3] }];       # commentaire






