define(["knockout","service","jquery","config/config","home"],function(c,a,e,b,g){function d(){var h=this;var j=false;h.isCPE=b.PRODUCT_TYPE=="CPE";h.hasRj45=b.RJ45_SUPPORT;h.hasSms=b.HAS_SMS;h.hasPhonebook=b.HAS_PHONEBOOK;h.isSupportSD=b.SD_CARD_SUPPORT;h.hasParentalControl=c.observable(b.HAS_PARENTAL_CONTROL&&j);h.deviceInfo=c.observable([]);if(b.WIFI_SUPPORT_QR_SWITCH){var i=a.getWifiBasic();h.showQRCode=b.WIFI_SUPPORT_QR_CODE&&i.show_qrcode_flag}else{h.showQRCode=b.WIFI_SUPPORT_QR_CODE}h.qrcodeSrc="./pic/qrcode_ssid_wifikey.png?_="+e.now();h.isHomePage=c.observable(false);if(window.location.hash=="#home"){h.isHomePage(true)}h.supportUnlock=b.NETWORK_UNLOCK_SUPPORT;h.unlockCode=c.observable();var k=a.getNetworkUnlockTimes();h.times=c.observable(k.unlock_nck_time);h.unlock=function(){showLoading();a.unlockNetwork({unlock_network_code:h.unlockCode()},function(l){h.unlockCode("");if(l&&l.result=="success"){successOverlay();if(window.location.hash=="#home"){setTimeout(function(){window.location.reload()},500)}else{window.location.hash="#home"}}else{var m=a.getNetworkUnlockTimes();h.times(m.unlock_nck_time);errorOverlay()}})};h.showOpModeWindow=function(){showSettingWindow("change_mode","opmode/opmode_popup","opmode/opmode_popup",400,300,function(){})};h.isLoggedIn=c.observable(false);h.enableFlag=c.observable(false);h.refreshOpmodeInfo=function(){var m=a.getStatusInfo();h.isLoggedIn(m.isLoggedIn);if(!j&&checkCableMode(m.blc_wan_mode)){window.location.reload();return}j=checkCableMode(m.blc_wan_mode);h.hasParentalControl(b.HAS_PARENTAL_CONTROL&&j);if(j&&m.ethWanMode.toUpperCase()=="DHCP"){h.enableFlag(true)}else{if((!j&&m.connectStatus!="ppp_disconnected")||(j&&m.rj45ConnectStatus!="idle"&&m.rj45ConnectStatus!="dead")){h.enableFlag(false)}else{h.enableFlag(true)}}var n=(m.blc_wan_mode=="AUTO_PPP"||m.blc_wan_mode=="AUTO_PPPOE")?"AUTO":m.blc_wan_mode;var l="";switch(n){case"AUTO":l="opmode_auto";break;case"PPPOE":l="opmode_cable";break;case"PPP":l="opmode_gateway";break;default:break}e("#opmode").attr("data-trans",l).text(e.i18n.prop(l))};if(h.hasRj45){h.refreshOpmodeInfo();addInterval(function(){h.refreshOpmodeInfo()},1000)}}function f(){var h=e("#container")[0];c.cleanNode(h);var i=new d();c.applyBindings(i,h);e("#frmNetworkLock").validate({submitHandler:function(){i.unlock()},rules:{txtLockNumber:"unlock_code_check"}})}return{init:f}});