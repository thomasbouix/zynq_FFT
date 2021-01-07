# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DATA_LEN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LEN_PKT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SAMPLE_LEN" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_LEN { PARAM_VALUE.DATA_LEN } {
	# Procedure called to update DATA_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_LEN { PARAM_VALUE.DATA_LEN } {
	# Procedure called to validate DATA_LEN
	return true
}

proc update_PARAM_VALUE.LEN_PKT { PARAM_VALUE.LEN_PKT } {
	# Procedure called to update LEN_PKT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LEN_PKT { PARAM_VALUE.LEN_PKT } {
	# Procedure called to validate LEN_PKT
	return true
}

proc update_PARAM_VALUE.SAMPLE_LEN { PARAM_VALUE.SAMPLE_LEN } {
	# Procedure called to update SAMPLE_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SAMPLE_LEN { PARAM_VALUE.SAMPLE_LEN } {
	# Procedure called to validate SAMPLE_LEN
	return true
}


proc update_MODELPARAM_VALUE.DATA_LEN { MODELPARAM_VALUE.DATA_LEN PARAM_VALUE.DATA_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_LEN}] ${MODELPARAM_VALUE.DATA_LEN}
}

proc update_MODELPARAM_VALUE.LEN_PKT { MODELPARAM_VALUE.LEN_PKT PARAM_VALUE.LEN_PKT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LEN_PKT}] ${MODELPARAM_VALUE.LEN_PKT}
}

proc update_MODELPARAM_VALUE.SAMPLE_LEN { MODELPARAM_VALUE.SAMPLE_LEN PARAM_VALUE.SAMPLE_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SAMPLE_LEN}] ${MODELPARAM_VALUE.SAMPLE_LEN}
}

