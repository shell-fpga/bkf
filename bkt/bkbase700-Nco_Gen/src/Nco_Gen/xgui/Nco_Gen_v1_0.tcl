# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "BKP_BASE_index" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NCO_nums" -parent ${Page_0}


}

proc update_PARAM_VALUE.BKP_BASE_index { PARAM_VALUE.BKP_BASE_index } {
	# Procedure called to update BKP_BASE_index when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BKP_BASE_index { PARAM_VALUE.BKP_BASE_index } {
	# Procedure called to validate BKP_BASE_index
	return true
}

proc update_PARAM_VALUE.NCO_nums { PARAM_VALUE.NCO_nums } {
	# Procedure called to update NCO_nums when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NCO_nums { PARAM_VALUE.NCO_nums } {
	# Procedure called to validate NCO_nums
	return true
}


proc update_MODELPARAM_VALUE.BKP_BASE_index { MODELPARAM_VALUE.BKP_BASE_index PARAM_VALUE.BKP_BASE_index } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BKP_BASE_index}] ${MODELPARAM_VALUE.BKP_BASE_index}
}

proc update_MODELPARAM_VALUE.NCO_nums { MODELPARAM_VALUE.NCO_nums PARAM_VALUE.NCO_nums } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NCO_nums}] ${MODELPARAM_VALUE.NCO_nums}
}

