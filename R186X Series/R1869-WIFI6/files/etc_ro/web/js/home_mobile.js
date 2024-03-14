define(["knockout","service","jquery","config/config","underscore","status/statusBar","echarts"],function(j,e,d,a,g,f,c){function b(){var k=this;k.current_pdpstatus_trans=j.observable("");k.current_pdpstatus_text=j.observable("");k.wirelessDeviceNum=j.observable(e.getStatusInfo().wirelessDeviceNum);i.refreshHomeData(k);addInterval(function(){i.refreshHomeData(k)},1000);k.pageSwitchPC=function(){showConfirm("confirm_page_switch",function(){window.location="index.html"})};k.logout_mobile=function(){showConfirm("confirm_logout",function(){manualLogout=true;e.logout({},function(){if(e.pageIsMobile()){window.location="index_mobile.html"}else{window.location="index.html"}})})}}var i={initStatus:null,refreshHomeData:function(l){var m=e.getConnectStatus();var k=d("#net-status");if(m.connect_status=="ppp_connected"){l.current_pdpstatus_trans("mobile_pdp_connect_succ");l.current_pdpstatus_text(d.i18n.prop("mobile_pdp_connect_succ"));if(k.hasClass("color-red")){k.removeClass("color-red")}}else{l.current_pdpstatus_trans("mobile_pdp_connect_faile");l.current_pdpstatus_text(d.i18n.prop("mobile_pdp_connect_faile"));if(!k.hasClass("color-red")){k.addClass("color-red")}}i.refreshStationInfo(l)},oldUsedData:null,oldAlarmData:null,refreshStationInfo:function(k){var l=e.getStatusInfo();k.wirelessDeviceNum(l.wirelessDeviceNum);if(refreshCount%10==2){e.getAttachedCableDevices({},function(o){k.wireDeviceNum(o.attachedDevices.length)})}var n=d("#sim_status");var m=d("#status_info");if(l.simStatus!="modem_init_complete"){if(n.hasClass("display-none")){n.removeClass("display-none")}if(!m.hasClass("no-sim-width")){m.addClass("no-sim-width")}}else{if(!n.hasClass("display-none")){n.addClass("display-none")}if(m.hasClass("no-sim-width")){m.removeClass("no-sim-width")}}}};function h(){refreshCount=0;i.oldUsedData=null;i.oldAlarmData=null;var k=d("#container")[0];j.cleanNode(k);var l=new b();j.applyBindings(l,k)}return{init:h}});