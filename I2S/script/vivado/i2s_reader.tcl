create_project project_1 /home/thomas/polytech/projet_implementation/project_1 -part xc7z020clg484-1


ipx::infer_core -vendor user.org -library user -taxonomy /UserIP /home/thomas/polytech/projet_implementation/git/I2S/synth
ipx::infer_core: Time (s): cpu = 00:00:04 ; elapsed = 00:00:05 . Memory (MB): peak = 6752.465 ; gain = 0.004 ; free physical = 1048 ; free virtual = 11962
ipx::edit_ip_in_project -upgrade true -name i2s_reader -directory /home/thomas/polytech/projet_implementation/git/I2S/ip /home/thomas/polytech/projet_implementation/git/I2S/synth/component.xml
ipx::edit_ip_in_project: Time (s): cpu = 00:00:11 ; elapsed = 00:00:05 . Memory (MB): peak = 6778.379 ; gain = 25.914 ; free physical = 976 ; free virtual = 11931
ipx::current_core /home/thomas/polytech/projet_implementation/git/I2S/synth/component.xml
update_compile_order -fileset sources_1
