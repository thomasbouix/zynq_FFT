set ip_name "vga_controller"

create_project project_1 . -part xc7z020clg484-1 -force
set_property ip_repo_paths ip_repo [current_project]
update_ip_catalog
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property target_language VHDL [current_project]
import_files -fileset sources_1 -norecurse synth/$ip_name.vhd
import_files -fileset sim_1 -norecurse sim/$ip_name\_tb.vhd
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project -root_dir ip_repo/$ip_name -vendor user.org -library user -taxonomy /UserIP -import_files -force -generated_files
set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
update_ip_catalog -rebuild

