# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"


}

proc update_PARAM_VALUE.ready_bit { PARAM_VALUE.ready_bit } {
	# Procedure called to update ready_bit when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ready_bit { PARAM_VALUE.ready_bit } {
	# Procedure called to validate ready_bit
	return true
}


proc update_MODELPARAM_VALUE.ready_bit { MODELPARAM_VALUE.ready_bit PARAM_VALUE.ready_bit } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ready_bit}] ${MODELPARAM_VALUE.ready_bit}
}

