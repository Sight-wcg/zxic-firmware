define(["jquery","knockout","config/config","service","underscore"],function(f,m,b,g,j){var d=false;var k=j.map(b.WIFI_WEP_SUPPORT?b.AUTH_MODES_WEP:b.AUTH_MODES,function(n){return new Option(n.name,n.value)});function c(n){var o=[];for(var p=1;p<=n;p++){o.push(new Option(p,p))}return o}function a(){var o=this;var p=i();var n=g.getWifiAdvance();o.adBand=m.observable(n.wifiBand);o.adMode=m.observable(n.mode);o.showQRSwitch=b.WIFI_SUPPORT_QR_CODE&&b.WIFI_SUPPORT_QR_SWITCH;o.showQR=m.observable(p.show_qrcode_flag);if(b.WIFI_SUPPORT_QR_SWITCH){o.showQRCode=m.observable(b.WIFI_SUPPORT_QR_CODE&&o.showQR())}else{o.showQRCode=m.observable(b.WIFI_SUPPORT_QR_CODE)}o.qrcodeSrc="./pic/qrcode_ssid_wifikey.png?_="+f.now();o.origin_ap_station_enable=p.ap_station_enable;o.hasWifiSwitch=b.WIFI_SWITCH_SUPPORT;o.hasMultiSSID=b.HAS_MULTI_SSID;o.showIsolated=b.SHOW_WIFI_AP_ISOLATED;o.wifi_enable=m.observable(p.wifi_enable);o.hasAPStation=b.AP_STATION_SUPPORT;o.hasWlanMacfilter=b.HAS_BLACK_AND_WHITE_FILTER;o.hasWifiWep=b.WIFI_WEP_SUPPORT;o.isShowSSIDInfoDiv=m.observable(false);if(b.WIFI_SWITCH_SUPPORT){if(p.wifi_enable=="1"){o.isShowSSIDInfoDiv(true)}else{o.isShowSSIDInfoDiv(false)}}else{o.isShowSSIDInfoDiv(true)}o.multi_ssid_enable=m.observable(p.multi_ssid_enable);o.origin_multi_ssid_enable=p.multi_ssid_enable;o.maxStationNumber=m.computed(function(){return b.MAX_STATION_NUMBER});o.modes=m.observableArray(k);o.selectedMode=m.observable(p.AuthMode);o.passPhrase=m.observable(p.passPhrase);o.showPassword=m.observable(false);o.ssid=m.observable(p.SSID);o.broadcast=m.observable(p.broadcast=="1"?"1":"0");o.apIsolation=m.observable(p.apIsolation=="1"?"1":"0");o.cipher=p.cipher;o.selectedStation=m.observable(p.MAX_Access_num);o.maxStations=m.observableArray(c(p.MAX_Station_num));o.encryptType=m.observable(p.encryptType);o.keyID=m.observable(p.keyID);o.wepPassword=m.observable("");o.m_modes=m.observableArray(k);o.m_selectedMode=m.observable(p.m_AuthMode);o.m_passPhrase=m.observable(p.m_passPhrase);o.m_showPassword=m.observable(false);o.m_ssid=m.observable(p.m_SSID);o.m_broadcast=m.observable(p.m_broadcast=="1"?"1":"0");o.m_apIsolation=m.observable(p.m_apIsolation=="1"?"1":"0");o.m_cipher=p.m_cipher;o.m_selectedStation=m.observable(p.m_MAX_Access_num);o.m_maxStations=m.observableArray(c(p.MAX_Station_num));o.pageSwitchPC=function(){showConfirm("confirm_page_switch",function(){window.location="index.html"})};o.logout_mobile=function(){showConfirm("confirm_logout",function(){manualLogout=true;g.logout({},function(){if(g.pageIsMobile()){window.location="index_mobile.html"}else{window.location="index.html"}})})};o.getWepPassword=function(){return o.keyID()=="3"?p.Key4Str1:(o.keyID()=="2"?p.Key3Str1:o.keyID()=="1"?p.Key2Str1:p.Key1Str1)};o.wepPassword(o.getWepPassword());o.profileChangeHandler=function(r,q){f("#pwdWepKey").parent().find("label[class='error']").hide();o.wepPassword(o.getWepPassword());return true};o.clickeye=function(){var r=document.getElementById("pwdWPAKey");var q=document.getElementById("eyeImg");if(r.type=="text"){r.type="password";q.src="pic/eye_show.png"}else{r.type="text";q.src="pic/eye_hide.png"}};o.clear=function(q){if(q=="switch"){o.multi_ssid_enable(p.multi_ssid_enable);o.wifi_enable(p.wifi_enable)}else{if(q=="ssid1"){o.selectedMode(p.AuthMode);o.passPhrase(p.passPhrase);o.ssid(p.SSID);o.broadcast(p.broadcast=="1"?"1":"0");o.cipher=p.cipher;o.selectedStation(p.MAX_Access_num);o.apIsolation(p.apIsolation=="1"?"1":"0");if(b.WIFI_WEP_SUPPORT){o.encryptType(p.encryptType);o.keyID(p.keyID);o.wepPassword(o.getWepPassword())}}else{if(q=="ssid2"){o.m_selectedMode(p.m_AuthMode);o.m_passPhrase(p.m_passPhrase);o.m_ssid(p.m_SSID);o.m_broadcast(p.m_broadcast=="1"?"1":"0");o.m_cipher=p.m_cipher;o.m_selectedStation(p.m_MAX_Access_num);o.m_apIsolation(p.m_apIsolation=="1"?"1":"0")}else{clearTimer();clearValidateMsg();l()}}}o.saveSSID1=function(){showConfirm("wifi_disconnect_confirm",function(){o.saveSSID1Action()})}};o.checkSettings=function(s){var q=e();if(s=="ssid1"||s=="ssid2"){if(s=="ssid1"){var r=g.getStatusInfo().ssid1AttachedNum;if(parseInt(o.selectedStation())<r){showAlert("Extend_accessDevice");return true}}else{var r=g.getStatusInfo().ssid2AttachedNum;if(parseInt(o.m_selectedStation())<r){showAlert("Extend_accessDevice");return true}}}if(q.wpsFlag=="1"){showAlert("wps_on_info");return true}if(b.HAS_MULTI_SSID&&p.multi_ssid_enable=="1"){if((s=="ssid1"&&parseInt(o.selectedStation())+parseInt(p.m_MAX_Access_num)>p.MAX_Station_num)||(s=="ssid2"&&parseInt(o.m_selectedStation())+parseInt(p.MAX_Access_num)>p.MAX_Station_num)){showAlert({msg:"multi_ssid_max_access_number_alert",params:p.MAX_Station_num});return true}}return false};o.saveSSID1=function(){if(o.checkSettings("ssid1")){return}showConfirm("wifi_disconnect_confirm",function(){o.saveSSID1Action()})};o.saveSSID1Action=function(){showLoading("waiting");var r={};r.AuthMode=o.selectedMode();r.passPhrase=o.passPhrase();r.SSID=o.ssid();r.broadcast=o.broadcast();r.station=o.selectedStation();r.cipher=o.selectedMode()=="WPA2PSK"?1:2;r.NoForwarding=o.apIsolation();r.show_qrcode_flag=o.showQR()==true?1:0;if(b.WIFI_WEP_SUPPORT){if(r.AuthMode=="WPAPSK"||r.AuthMode=="WPA2PSK"||r.AuthMode=="WPAPSKWPA2PSK"||r.AuthMode=="WPA3Personal"||r.AuthMode=="WPA2WPA3"){}else{if(r.AuthMode=="SHARED"){r.encryptType="WEP"}else{r.encryptType=o.encryptType()}}r.wep_default_key=o.keyID();r.wep_key_1=p.Key1Str1;r.wep_key_2=p.Key2Str1;r.wep_key_3=p.Key3Str1;r.wep_key_4=p.Key4Str1;var q="0";if(o.wepPassword().length=="5"||o.wepPassword().length=="13"){q="1"}else{q="0"}if(o.keyID()=="1"){r.wep_key_2=o.wepPassword();r.WEP2Select=q}else{if(o.keyID()=="2"){r.wep_key_3=o.wepPassword();r.WEP3Select=q}else{if(o.keyID()=="3"){r.wep_key_4=o.wepPassword();r.WEP4Select=q}else{r.wep_key_1=o.wepPassword();r.WEP1Select=q}}}}g.setWifiBasic(r,function(s){if(s.result=="success"){if(d){setTimeout(function(){successOverlay();setTimeout(function(){window.location.reload()},1000);o.clear()},15000)}else{addInterval(function(){var t=i();if(t.wifi_enable=="1"){successOverlay();o.clear()}},1000)}}else{errorOverlay()}})};o.saveSSID2=function(){if(o.checkSettings("ssid2")){return}showConfirm("wifi_disconnect_confirm",function(){o.saveSSID2Action()})};o.saveSSID2Action=function(){showLoading("waiting");var q={};q.m_AuthMode=o.m_selectedMode();q.m_passPhrase=o.m_passPhrase();q.m_SSID=o.m_ssid();q.m_broadcast=o.m_broadcast();q.m_station=o.m_selectedStation();q.m_cipher=o.m_selectedMode()=="WPA2PSK"?1:2;q.m_NoForwarding=o.m_apIsolation();q.m_show_qrcode_flag=o.showQR()==true?1:0;g.setWifiBasic4SSID2(q,function(r){if(r.result=="success"){if(d){setTimeout(function(){successOverlay();setTimeout(function(){window.location.reload()},1000);o.clear()},15000)}else{addInterval(function(){var s=i();if(s.wifi_enable=="1"){successOverlay();o.clear()}},1000)}}else{errorOverlay()}})};o.setMultiSSIDSwitch=function(){if(o.checkSettings("switch")){return}var q=function(){showLoading("waiting");var s={};s.m_ssid_enable=o.multi_ssid_enable();if(b.WIFI_SWITCH_SUPPORT){s.wifiEnabled=o.wifi_enable()}g.setWifiBasicMultiSSIDSwitch(s,function(t){if(t.result=="success"){if(d){setTimeout(function(){successOverlay();setTimeout(function(){window.location.reload()},1000);g.refreshAPStationStatus();o.clear()},15000)}else{addInterval(function(){var u=i();g.refreshAPStationStatus();if(u.wifi_enable==o.wifi_enable()){successOverlay();o.clear()}},1000)}}else{errorOverlay()}})};var r=g.getStatusInfo();if(b.HAS_MULTI_SSID&&o.wifi_enable()=="1"){if(o.multi_ssid_enable()=="1"&&b.AP_STATION_SUPPORT&&o.origin_ap_station_enable=="1"){if(r.wifiStatus){showConfirm("multi_ssid_enable_confirm2",function(){q()})}else{showConfirm("multi_ssid_enable_confirm",function(){q()})}}else{if(r.wifiStatus){showConfirm("wifi_disconnect_confirm2",function(){q()})}else{q()}}}else{q()}};o.showPasswordHandler=function(){f("#pwdWepKey").parent().find(".error").hide();f("#pwdWPAKey").parent().find(".error").hide();var q=f("#showPassword:checked");if(q&&q.length==0){o.showPassword(true)}else{o.showPassword(false)}};o.m_showPasswordHandler=function(){f("#m_passShow").parent().find(".error").hide();var q=f("#m_showPassword:checked");if(q&&q.length==0){o.m_showPassword(true)}else{o.m_showPassword(false)}};o.showQRHandler=function(){var q=f("#showQR:checked");if(q&&q.length==0){o.showQR(true)}else{o.showQR(false)}o.showQRCode(b.WIFI_SUPPORT_QR_CODE&&o.showQR())}}function i(){return g.getWifiBasic()}function e(){return g.getWpsInfo()}function h(){g.getParams({nv:"user_ip_addr"},function(n){g.getParams({nv:"station_list"},function(o){d=isWifiConnected(n.user_ip_addr,o.station_list)})})}function l(){var n=f("#container");m.cleanNode(n[0]);var p=new a();m.applyBindings(p,n[0]);addTimeout(function(){h()},600);function q(){var r=g.getAPStationBasic();if(r.ap_station_enable=="1"){}else{}}function o(){var r=g.getWdsInfo();if(r.currentMode!="0"){f("#frmWifiSwitch :input").each(function(){f(this).prop("disabled",true)});f("#frmSSID1 :input").each(function(){f(this).prop("disabled",true)});f("#frmSSID2 :input").each(function(){f(this).prop("disabled",true)})}else{f("#frmWifiSwitch :input").each(function(){f(this).prop("disabled",false)});f("#frmSSID1 :input").each(function(){f(this).prop("disabled",false)});f("#frmSSID2 :input").each(function(){f(this).prop("disabled",false)})}}f("#frmSSID1").validate({submitHandler:function(){p.saveSSID1()},rules:{ssid:"ssid",pwdWPAKey:"wifi_password_check"},errorPlacement:function(r,s){var t=s.attr("id");if(t=="pwdWPAKey"){r.insertAfter("#lblshowWPAPassword")}else{r.insertAfter(s)}}})}return{init:l}});