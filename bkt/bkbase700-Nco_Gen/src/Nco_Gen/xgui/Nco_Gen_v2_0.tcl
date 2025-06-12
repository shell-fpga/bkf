# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "timer_delay" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NCO_nums" -parent ${Page_0}


}

proc update_PARAM_VALUE.NCO_nums { PARAM_VALUE.NCO_nums } {
	# Procedure called to update NCO_nums when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NCO_nums { PARAM_VALUE.NCO_nums } {
	# Procedure called to validate NCO_nums
	return true
}

proc update_PARAM_VALUE.timer_delay { PARAM_VALUE.timer_delay } {
	# Procedure called to update timer_delay when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.timer_delay { PARAM_VALUE.timer_delay } {
	# Procedure called to validate timer_delay
	return true
}


proc update_MODELPARAM_VALUE.NCO_nums { MODELPARAM_VALUE.NCO_nums PARAM_VALUE.NCO_nums } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NCO_nums}] ${MODELPARAM_VALUE.NCO_nums}
}

proc update_MODELPARAM_VALUE.timer_delay { MODELPARAM_VALUE.timer_delay PARAM_VALUE.timer_delay } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.timer_delay}] ${MODELPARAM_VALUE.timer_delay}
}

