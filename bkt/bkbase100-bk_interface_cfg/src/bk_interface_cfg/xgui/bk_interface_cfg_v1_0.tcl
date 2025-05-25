# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "bkp_data_with" -parent ${Page_0}


}

proc update_PARAM_VALUE.BKT_BASE { PARAM_VALUE.BKT_BASE } {
	# Procedure called to update BKT_BASE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BKT_BASE { PARAM_VALUE.BKT_BASE } {
	# Procedure called to validate BKT_BASE
	return true
}

proc update_PARAM_VALUE.bkp_data_with { PARAM_VALUE.bkp_data_with } {
	# Procedure called to update bkp_data_with when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.bkp_data_with { PARAM_VALUE.bkp_data_with } {
	# Procedure called to validate bkp_data_with
	return true
}


proc update_MODELPARAM_VALUE.bkp_data_with { MODELPARAM_VALUE.bkp_data_with PARAM_VALUE.bkp_data_with } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.bkp_data_with}] ${MODELPARAM_VALUE.bkp_data_with}
}

proc update_MODELPARAM_VALUE.BKT_BASE { MODELPARAM_VALUE.BKT_BASE PARAM_VALUE.BKT_BASE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BKT_BASE}] ${MODELPARAM_VALUE.BKT_BASE}
}

