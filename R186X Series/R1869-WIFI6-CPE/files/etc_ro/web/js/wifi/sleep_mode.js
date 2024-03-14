define(["jquery","knockout","config/config","service","underscore"],function(c,i,a,d,g){var f=g.map(a.SLEEP_MODES,function(k){return new Option(k.name,k.value)});function b(){var k=this;var l=e();k.isCPE=a.PRODUCT_TYPE=="CPE";k.showTSWDiv=a.TSW_SUPPORT;k.showSleepDiv=a.WIFI_SLEEP_SUPPORT;k.hasUssd=a.HAS_USSD;k.hasUpdateCheck=a.HAS_UPDATE_CHECK;k.hasDdns=a.DDNS_SUPPORT;k.modes=i.observableArray(f);k.selectedMode=i.observable(l.sleepMode);var n=j();k.wifiRangeMode=i.observable(n.wifiRangeMode);k.setSleepMode=function(){showLoading("waiting");d.getWpsInfo({},function(o){if(o.radioFlag=="0"){showAlert("wps_wifi_off")}else{if(o.wpsFlag=="1"){showAlert("wps_on_info")}else{k.setSleepModeAct()}}})};k.setSleepModeAct=function(){var o={};o.sleepMode=k.selectedMode();d.setSleepMode(o,function(p){if(p.result=="success"){successOverlay()}else{errorOverlay()}})};k.setWifiRange=function(){d.getWpsInfo({},function(o){if(o.radioFlag=="0"){showAlert("wps_wifi_off")}else{if(o.wpsFlag=="1"){showAlert("wps_on_info")}else{showConfirm("wifi_sleep_confirm",function(){showLoading("waiting");k.setWifiRangeAct()})}}})};k.setWifiRangeAct=function(){var o={};o.wifiRangeMode=k.wifiRangeMode();d.setWifiRange(o,function(p){if(p.result=="success"){successOverlay()}else{errorOverlay()}})};var m=d.getTsw();k.openEnable=i.observable(m.openEnable==""?"0":m.openEnable);k.openH=i.observable(m.openH);k.openM=i.observable(m.openM);k.closeH=i.observable(m.closeH);k.closeM=i.observable(m.closeM);k.saveTsw=function(){if(k.openEnable()=="1"){if(Math.abs((k.openH()*60+parseInt(k.openM(),10))-(k.closeH()*60+parseInt(k.closeM(),10)))<10){showAlert("tsw_time_interval_alert");return false}showLoading("waiting");d.saveTsw({openEnable:k.openEnable(),closeEnable:k.openEnable(),openTime:leftInsert(k.openH(),2,"0")+":"+leftInsert(k.openM(),2,"0"),closeTime:leftInsert(k.closeH(),2,"0")+":"+leftInsert(k.closeM(),2,"0")},function(o){if(o&&o.result=="success"){successOverlay()}else{errorOverlay()}},c.noop)}else{showLoading("waiting");d.saveTsw({openEnable:k.openEnable(),closeEnable:k.openEnable()},function(o){if(o&&o.result=="success"){successOverlay()}else{errorOverlay()}},c.noop)}}}function j(){return d.getWifiRange()}function e(){return d.getSleepMode()}self.isShowFotaSwitch=i.observable(false);if(d.getfotaswitch().remo_fota_switch=="1"){self.isShowFotaSwitch(true)}else{self.isShowFotaSwitch(false)}function h(){var k=c("#container");i.cleanNode(k[0]);var l=new b();i.applyBindings(l,k[0]);c("#sleepModeForm").validate({submitHandler:function(){l.setSleepMode()}});c("#wifiRangeForm").validate({submitHandler:function(){l.setWifiRange()}});c("#frmTsw").validate({submitHandler:function(){l.saveTsw()},errorPlacement:function(m,n){if(n.attr("name")=="openH"||n.attr("name")=="openM"){c("#openErrorDiv").html(m)}else{if(n.attr("name")=="closeH"||n.attr("name")=="closeM"){c("#closeErrorDiv").html(m)}else{m.insertAfter(n)}}}})}return{init:h}});