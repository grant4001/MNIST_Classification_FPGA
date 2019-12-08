set_global_assignment -entity "PLL_MAIN" -library "lib_PLL_MAIN" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL_MAIN" -library "lib_PLL_MAIN" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "PLL_MAIN" -library "lib_PLL_MAIN" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL_MAIN" -name SPD_FILE [file join $::quartus(sip_path) "PLL_MAIN.spd"]

set_global_assignment -library "lib_PLL_MAIN" -name MISC_FILE [file join $::quartus(sip_path) "PLL_MAIN_sim/PLL_MAIN.vo"]
