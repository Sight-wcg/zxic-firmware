window.web_ui_is_test=false;require.config({paths:{text:"lib/require/text",tmpl:"../tmpl",underscore:"lib/underscore/underscore",knockout:"lib/knockout/knockout",jquery:"lib/require/require-jquery",jq_validate:"lib/jquery/jquery.validate",jq_additional:"lib/jquery/additional-methods",jq_i18n:"lib/jquery/jquery.i18n.properties-1.0.9",jq_translate:"lib/jquery/translate",jq_tmpl:"lib/jquery/jquery.tmpl.min",knockoutbase:"lib/knockout/knockout-3.4.2",jq_simplemodal:"lib/jquery/jquery.simplemodal-1.4.2",base64:"lib/base64",jqui:"lib/jqui/jquery-ui.min",echarts:"lib/echarts.min"},shim:{jq_additional:["jq_validate"],jq_translate:["jq_i18n"],knockoutbase:["jq_tmpl"],jq_simplemodal:["lib/bootstrap"]}});require(["service","config/config","util",web_ui_is_test?"simulate":""],function(a,e,c,d){if(web_ui_is_test){window.simulate=d}if(e.RJ45_SUPPORT){var b="menu";a.getOpMode({},function(g){e.blc_wan_mode=g.blc_wan_mode;switch(g.blc_wan_mode){case"AUTO_PPPOE":b="menu_pppoe";break;case"PPPOE":b="menu_pppoe";break;case"PPP":case"AUTO_PPP":b="menu_4ggateway";break;default:b="menu";break}f({menu:"config/"+e.DEVICE+"/"+b,config:"config/"+e.DEVICE+"/config"})})}else{f({menu:"config/"+e.DEVICE+"/menu",config:"config/"+e.DEVICE+"/config"})}function f(g){require([g.menu,g.config],function(h){require(["app","jq_additional","jq_translate","jq_simplemodal","base64"],function(i){i.init()})})}});