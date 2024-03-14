define(["jquery","knockout","config/config","service","underscore"],function(g,n,c,h,k){var e=false;function b(){var x=this;var v="";x.hasMultiSSID=c.HAS_MULTI_SSID;x.hasAPStation=c.AP_STATION_SUPPORT;x.hasWifiSwitch=c.WIFI_SWITCH_SUPPORT;x.hasWlanMacfilter=c.HAS_BLACK_AND_WHITE_FILTER;var w=k.map(c.AUTH_MODES_ALL,function(z){return new Option(z.name,z.value)});x.page={list:1,add:2,edit:3};var u=[{columnType:"radio",headerTextTrans:"option",rowText:"profileName",width:"10%"},{headerTextTrans:"ssid_title",rowText:"ssid",width:"30%"},{columnType:"image",headerTextTrans:"signal",rowText:"imgSignal",width:"30%"},{headerTextTrans:"security_mode",rowText:"authMode_show",width:"30%"}];var q=[{columnType:"radio",rowText:"index",width:"10%"},{headerTextTrans:"ssid_title",rowText:"ssid",width:"30%"},{columnType:"image",headerTextTrans:"signal",rowText:"imgSignal",width:"30%"},{headerTextTrans:"security_mode",rowText:"authMode_show",width:"30%"}];x.pageState=n.observable(x.page.list);var s=h.getAPStationBasic();x.origin_ap_station_enable=s.ap_station_enable;x.ap_station_enable=n.observable(s.ap_station_enable);x.apList=n.observable([]);if(x.origin_ap_station_enable=="1"){var y=h.getHotspotList();x.apList(a(y.hotspotList))}x.apSearchList=n.observable([]);x.connectButtonStatus=n.observable("disable");x.hasSelectFromUser=n.observable();x.showPassword=n.observable(false);x.isCableMode=n.observable();var p=h.getWifiBasic();x.wifi_enable=n.observable(p.wifi_enable);x.isShowSSIDInfoDiv=n.observable(false);if(c.WIFI_SWITCH_SUPPORT){if(p.wifi_enable=="1"){x.isShowSSIDInfoDiv(true)}else{x.isShowSSIDInfoDiv(false)}}else{x.isShowSSIDInfoDiv(true)}x.multi_ssid_enable=n.observable(p.multi_ssid_enable);x.showPasswordHandler=function(){g("#pwdWepKey").parent().find(".error").hide();g("#pwdWPAKey").parent().find(".error").hide();var z=g("#showPassword:checked");if(z&&z.length==0){x.showPassword(true)}else{x.showPassword(false)}};x.showWPAPasswordHandler=function(){g("#pwdWepKey").parent().find(".error").hide();g("#pwdWPAKey").parent().find(".error").hide();if(g("#showWPAPassword").is(":checked")){x.showPassword(true)}else{x.showPassword(false)}};function o(){var C=x.apGrid.radioSelectValue();if(!C){x.hasSelectFromUser(false);x.connectButtonStatus("disable");return}var A="";var z="";for(var B=0;B<x.apList().length;B++){var D=x.apList()[B];if(D.profileName==C){A=D.connectStatus;z=D.fromProvider;break}}if(A=="1"){x.connectButtonStatus("hide");x.hasSelectFromUser(false)}else{x.connectButtonStatus("show");x.hasSelectFromUser(z=="0")}}x.apGrid=new n.simpleGrid.viewModel({data:x.apList(),idName:"profileName",columns:u,pageSize:100,tmplType:"list",primaryColumn:"fromProvider",radioClickHandler:function(){o()}});x.apSearchGrid=new n.simpleGrid.viewModel({data:x.apSearchList(),idName:"index",columns:q,pageSize:100,tmplType:"list",radioClickHandler:function(){var A=x.apSearchGrid.radioSelectValue();var z=x.apSearchList();for(var B=0;B<z.length;B++){var C=z[B];if(C.index==A){x.profileName("");x.ssid(C.ssid);v=C.ssid;x.signal(C.signal);x.authMode(C.authMode);x.password(C.password);x.mac(C.mac);if(C.authMode=="WPAPSK"||C.authMode=="WPA2PSK"||C.authMode=="WPAPSKWPA2PSK"){x.encryptType_WPA(C.encryptType)}else{x.encryptType(C.encryptType)}x.keyID(C.keyID);renderCustomElement(g("#cipherGroup"));break}}}});x.computeConnectStatus=function(){o();var z=x.connectStatus();if(z=="ppp_connected"){x.current_status_trans("ap_station_wan_connected");x.current_status_text(g.i18n.prop("ap_station_wan_connected"));return}var A=x.connectWifiSSID();var B=x.connectWifiStatus();if(A&&B=="connect"){x.current_status_trans("ap_station_wlan_connected");x.current_status_text(g.i18n.prop("ap_station_wlan_connected"));return}x.current_status_trans("ap_station_no_connection");x.current_status_text(g.i18n.prop("ap_station_no_connection"))};var t=h.getStatusInfo();x.networkType=n.observable(t.networkType);x.networkOperator=n.observable(t.networkOperator);x.connectStatus=n.observable(t.connectStatus);x.connectWifiStatus=n.observable(t.connectWifiStatus);x.connectWifiProfile=n.observable(t.connectWifiProfile);x.connectWifiSSID=n.observable(t.connectWifiSSID);x.current_status_trans=n.observable("");x.current_status_text=n.observable("");x.current_status=n.computed(function(){x.computeConnectStatus()});x.modes=w;x.profileName=n.observable("");x.ssid=n.observable();x.signal=n.observable("0");x.authMode=n.observable();x.password=n.observable();x.encryptType=n.observable();x.encryptType_WPA=n.observable("TKIPCCMP");x.keyID=n.observable("0");x.mac=n.observable();x.openAddPage=function(){if(m()){return}if(d()){return}x.clear();r()};x.openListPage=function(){if(m()){return}if(d()){return}x.clear();x.pageState(x.page.list);x.apGrid.data(x.apList());x.computeConnectStatus()};x.addHotspot=function(){if(m()){return}if(d()){return}if(x.pageState()==x.page.add&&x.apList().length>=c.AP_STATION_LIST_LENGTH){showAlert({msg:"ap_station_exceed_list_max",params:c.AP_STATION_LIST_LENGTH});return}showLoading("waiting");var z={};var A=x.apGrid.radioSelectValue();z.profileName=x.profileName();z.ssid=x.ssid();z.signal=x.signal();z.authMode=x.authMode();z.password=x.password();if(z.authMode=="WPAPSK"||z.authMode=="WPA2PSK"||z.authMode=="WPAPSKWPA2PSK"){z.encryptType=x.encryptType_WPA()}else{if(z.authMode=="SHARED"){z.encryptType="WEP"}else{z.encryptType=x.encryptType()}}z.keyID=x.keyID();z.mac=(x.mac()==""||x.ssid()!=v)?"0F:00:00:00:00:00":x.mac();z.apList=x.apList();h.saveHotspot(z,function(B){x.callback(B,true)})};x.deleteHotspot=function(){if(m()){return}if(d()){return}showConfirm("confirm_data_delete",function(){var z={};z.profileName=x.apGrid.radioSelectValue();z.apList=x.apList();showLoading("waiting");h.deleteHotspot(z,function(A){x.callback(A,true)})})};x.openEditPage=function(){if(m()){return}if(d()){return}var B=x.apGrid.radioSelectValue();var z=x.apList();for(var A=0;A<z.length;A++){var C=z[A];if(C.profileName==B){x.profileName(B);x.ssid(C.ssid);x.signal(C.signal);x.authMode(C.authMode);x.password(C.password);x.mac(C.mac);if(C.authMode=="WPAPSK"||C.authMode=="WPA2PSK"||C.authMode=="WPAPSKWPA2PSK"){x.encryptType_WPA(C.encryptType)}else{x.encryptType(C.encryptType)}x.keyID(C.keyID)}}x.pageState(x.page.edit)};x.connectHotspot=function(){if(m()){return}if(d()){return}var B=x.apGrid.radioSelectValue();var F=x.apList();function G(K,I){var M=[];var H=[];for(var J=0;J<I.length;J++){if(I[J].fromProvider=="1"){M.push(F[J])}else{if(I[J].profileName==K){M.push(F[J])}else{H.push(F[J])}}}var L=M.concat(H);h.saveHotspot({apList:L},function(N){if(N&&N.result=="success"){F=L;x.apList(a(F))}})}function A(){showLoading("connecting");var H={};var J=-1;var K="";for(var I=0;I<F.length;I++){if(F[I].profileName==B){J=I;K=F[I].ssid;H.EX_SSID1=F[I].ssid;H.EX_AuthMode=F[I].authMode;H.EX_EncrypType=F[I].encryptType;H.EX_DefaultKeyID=F[I].keyID;H.EX_WEPKEY=F[I].password;H.EX_WPAPSK1=F[I].password;H.EX_wifi_profile=F[I].profileName;H.EX_mac=F[I].mac;break}}x.connectWifiSSID(K);x.connectWifiStatus("connecting");x.apGrid.setRadioSelect(B);x.connectButtonStatus("disable");h.connectHotspot(H,function(L){if(L&&L.result=="success"){x.connectButtonStatus("disable");addTimeout(E,3000)}else{if(L&&L.result=="processing"){showAlert("ap_station_processing")}else{M[J].connectStatus="0";x.connectButtonStatus("show");x.connectWifiStatus("disconnect");hideLoading();errorOverlay()}}var M=h.getHotspotList();x.apList(a(M.hotspotList));x.connectWifiSSID(K);x.connectWifiProfile(B);x.apGrid.data([]);x.apGrid.data(x.apList());x.apGrid.setRadioSelect(B)})}var C=0;var D=false;function E(){C=C+1;if(C>60){hideLoading();errorOverlay();return}if(!D){var H=h.getStatusInfo();if(H.connectWifiStatus=="connect"){D=true}else{addTimeout(E,1000)}}if(D){h.getHotspotList({},function(M){for(var J=0,I=M.hotspotList.length;J<I;J++){var L=M.hotspotList[J];if(L.profileName==B){if(L.connectStatus=="1"){hideLoading();return}else{var K={msg:"ap_connect_error",params:[L.ssid]};showAlert(K);return}break}}addTimeout(E,1000)})}}var z=h.getStatusInfo();if(z.connectStatus=="ppp_connecting"||z.connectStatus=="ppp_connected"){showConfirm("ap_station_connect_change_alert",function(){showLoading();A()})}else{A()}};x.disconnectHotspot=function(){if(d()){return}showLoading("disconnecting");h.disconnectHotspot({},function(z){x.callback(z,true)})};x.searchHotspot=function(){if(m()){return}if(d()){return}r()};function r(){var A=0;function z(){var B=h.getSearchHotspotList();if(B.scan_finish!="0"){if("2"==B.scan_finish){hideLoading();showAlert("ap_station_processing")}else{x.apSearchList(a(B.hotspotList));x.apSearchGrid.data(x.apSearchList());hideLoading()}}else{if(A<=60){A=A+1;addTimeout(z,1000)}else{hideLoading();showAlert("ap_station_search_hotspot_fail")}}}showLoading("scanning");h.searchHotspot({},function(B){if(B&&B.result=="success"){if(x.pageState()!=x.page.add){x.pageState(x.page.add)}z()}else{if(B&&B.result=="processing"){hideLoading();showAlert("ap_station_processing")}else{if(x.pageState()!=x.page.add){x.pageState(x.page.add)}hideLoading();showAlert("ap_station_search_hotspot_fail")}}})}x.clear=function(){x.apSearchGrid.clearRadioSelect();x.profileName("");x.ssid("");x.signal("0");x.authMode("OPEN");x.password("");x.encryptType("NONE");x.encryptType_WPA("TKIPCCMP");x.keyID("0");x.mac("")};x.apply=function(){if(m()){return}if(d()){return}function z(){showLoading("waiting");var B={};B.ap_station_enable=x.ap_station_enable();h.setAPStationBasic(B,function(C){if(x.origin_ap_station_enable==x.ap_station_enable()){x.callback(C,true)}else{x.callback2(C,true)}});h.refreshAPStationStatus()}if(c.HAS_MULTI_SSID){var A=h.getWifiBasic();if(x.ap_station_enable()=="1"&&A.multi_ssid_enable=="1"){showConfirm("ap_station_enable_confirm",z)}else{z()}}else{z()}};x.callback=function(A,z){if(A){if(z){l();g("#apList").translate()}if(A.result=="success"){successOverlay()}else{if(A.result=="spot_connecting"||A.result=="spot_connected"){showAlert("ap_station_update_fail")}else{if(A.result=="processing"){showAlert("ap_station_processing")}else{if(A.result=="exist"){showAlert("ap_station_exist")}else{errorOverlay()}}}}}else{errorOverlay()}};x.callback2=function(A,z){if(A){if(e){setTimeout(function(){if(A.result=="success"){successOverlay();setTimeout(function(){window.location.reload()},1000);clearTimer();clearValidateMsg();l()}else{if(A.result=="spot_connecting"||A.result=="spot_connected"){showAlert("ap_station_update_fail")}else{if(A.result=="processing"){showAlert("ap_station_processing")}else{errorOverlay()}}}},15000)}else{addInterval(function(){var B=h.getWifiBasic();if(B.wifi_enable=="1"){clearTimer();clearValidateMsg();l();g("#apList").translate();if(A.result=="success"){successOverlay()}else{if(A.result=="spot_connecting"||A.result=="spot_connected"){showAlert("ap_station_update_fail")}else{errorOverlay()}}}},1000)}}else{errorOverlay()}};x.setMultiSSIDSwitch=function(){if(x.checkSettings("switch")){return}var z=function(){showLoading("waiting");var B={};B.m_ssid_enable=x.multi_ssid_enable();if(c.WIFI_SWITCH_SUPPORT){B.wifiEnabled=x.wifi_enable()}h.setWifiBasicMultiSSIDSwitch(B,function(C){if(C.result=="success"){if(e){setTimeout(function(){successOverlay();setTimeout(function(){window.location.reload()},1000);clearTimer();clearValidateMsg();h.refreshAPStationStatus();l()},15000)}else{addInterval(function(){var D=h.getWifiBasic();if(D.wifi_enable==x.wifi_enable()){successOverlay();clearTimer();clearValidateMsg();h.refreshAPStationStatus();l()}},1000)}}else{errorOverlay()}})};var A=h.getStatusInfo();if(c.HAS_MULTI_SSID&&x.wifi_enable()=="1"){if(x.multi_ssid_enable()=="1"&&c.AP_STATION_SUPPORT&&x.origin_ap_station_enable=="1"){if(A.wifiStatus){showConfirm("multi_ssid_enable_confirm2",function(){z()})}else{showConfirm("multi_ssid_enable_confirm",function(){z()})}}else{if(A.wifiStatus){showConfirm("wifi_disconnect_confirm2",function(){z()})}else{z()}}}else{z()}};x.checkSettings=function(A){var z=h.getWpsInfo();if(z.wpsFlag=="1"){showAlert("wps_on_info");return true}if(c.HAS_MULTI_SSID&&s.multi_ssid_enable=="1"){if((A=="ssid1"&&parseInt(x.selectedStation())+parseInt(s.m_MAX_Access_num)>s.MAX_Station_num)||(A=="ssid2"&&parseInt(x.m_selectedStation())+parseInt(s.MAX_Access_num)>s.MAX_Station_num)){showAlert({msg:"multi_ssid_max_access_number_alert",params:s.MAX_Station_num});return true}}return false}}function a(q){var r=[];for(var p=0;p<q.length;p++){q[p].index=p;var o="";if(q[p].connectStatus=="1"){if(q[p].authMode.toLowerCase()=="open"&&q[p].encryptType.toLowerCase()=="none"){o="pic/wifi_connected.png"}else{o="pic/wifi_lock_connected.png"}}else{if(q[p].authMode.toLowerCase()=="open"&&q[p].encryptType.toLowerCase()=="none"){o="pic/wifi_signal_"+q[p].signal+".png"}else{o="pic/wifi_lock_signal_"+q[p].signal+".png"}}q[p].imgSignal=o;q[p].authMode_show=g.i18n.prop("ap_station_security_mode_"+q[p].authMode)}return q}function m(){var o=h.getWpsInfo();if(o.radioFlag=="0"){showAlert("wps_wifi_off");return true}}function d(){var o=h.getWpsInfo();if(o.wpsFlag=="1"){showAlert("wps_on_info");return true}}function i(o){if(o){g("#frmAPStation :input").each(function(){g(this).attr("disabled",true)});clearValidateMsg()}else{g("#frmAPStation :input[id!='btnDelete'][id!='btnEdit'][id!='btnConnect']").each(function(){g(this).attr("disabled",false)})}}function f(o){g("#showPassword").change(function(){o.showPasswordHandler()});g("#showWPAPassword").change(function(){o.showWPAPasswordHandler()})}function j(){h.getParams({nv:"user_ip_addr"},function(o){h.getParams({nv:"station_list"},function(p){e=isWifiConnected(o.user_ip_addr,p.station_list)})})}function l(){var o=g("#container")[0];n.cleanNode(o);var p=new b();n.applyBindings(p,o);f(p);function q(r){var s=h.getStatusInfo();if(s.multi_ssid_enable=="1"){}else{p.isCableMode(checkCableMode(s.blc_wan_mode));p.networkType(s.networkType);p.connectStatus(s.connectStatus);p.connectWifiProfile(s.connectWifiProfile);p.connectWifiSSID(s.connectWifiSSID);p.connectWifiStatus(s.connectWifiStatus);p.computeConnectStatus();h.getHotspotList({},function(u){var t=a(u.hotspotList);p.apList(t);var w=p.apGrid.data();if(t.length>0&&t[0].connectStatus=="1"&&t[0].profileName!=w[0].profileName){p.apGrid.data([]);p.apGrid.data(p.apList());p.apGrid.setRadioSelect(t[0].profileName)}renderCustomElement(g("#apList"));var v=g("input[type='radio']","#apList").each(function(){for(var z=0,x=t.length;z<x;z++){if(t[z].profileName==g(this).val()){var y=g(this).parent().parent().find("img")[0];y.src=t[z].imgSignal;if(r){if(t[z].connectStatus=="1"){p.hasSelectFromUser(false);p.connectButtonStatus("disable")}}}}})})}}q(true);clearTimer();addInterval(function(){q(false);j()},1000);g("#frmWifiSwitch").validate({submitHandler:function(){p.setMultiSSIDSwitch()}});g("#frmAPStation").validate({submitHandler:function(){p.addHotspot()},rules:{txtSSID:"ssid_ap"},errorPlacement:function(r,s){var t=s.attr("id");if(t=="pwdWepKey"||t=="txtWepKey"){r.insertAfter("#lblShowPassword")}else{if(t=="pwdWPAKey"||t=="txtWPAKey"){r.insertAfter("#lblshowWPAPassword")}else{r.insertAfter(s)}}}})}return{init:l}});