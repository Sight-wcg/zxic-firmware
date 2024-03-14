define(["knockout","service","jquery","config/config","home","opmode/opmode"],function(l,e,d,c,f,h){var i={CONNECTED:1,DISCONNECTED:2,CONNECTING:3,DISCONNECTING:4};var m={WIRELESS:1,CABLE:2,AUTO:3};var b=0;var g=window.language;function a(){var z=this;var v=e.getStatusInfo();var y="PPPOE"==v.blc_wan_mode||"AUTO_PPPOE"==v.blc_wan_mode;z.hasRj45=c.RJ45_SUPPORT;z.hasSms=c.HAS_SMS;z.hasPhonebook=c.HAS_PHONEBOOK;z.isSupportSD=c.SD_CARD_SUPPORT;z.hasParentalControl=l.observable(c.HAS_PARENTAL_CONTROL&&y);z.pageState={NO_SIM:0,WAIT_PIN:1,WAIT_PUK:2,PUK_LOCKED:3,LOADING:4};if(c.WIFI_SUPPORT_QR_SWITCH){var s=e.getWifiBasic();z.showQRCode=c.WIFI_SUPPORT_QR_CODE&&s.show_qrcode_flag}else{z.showQRCode=c.WIFI_SUPPORT_QR_CODE}z.qrcodeSrc="./pic/qrcode_ssid_wifikey.png?_="+d.now();z.isHomePage=l.observable(false);if(window.location.hash=="#home"){z.isHomePage(true)}z.hasSms=c.HAS_SMS;z.hasPhonebook=c.HAS_PHONEBOOK;z.isSupportSD=c.SD_CARD_SUPPORT;z.isCPE=c.PRODUCT_TYPE=="CPE";z.hasRj45=c.RJ45_SUPPORT;z.notDataCard=c.PRODUCT_TYPE!="DATACARD";var s=e.getWifiBasic();if(c.WIFI_SUPPORT_QR_SWITCH){z.showQRCode=c.WIFI_SUPPORT_QR_CODE&&s.show_qrcode_flag}else{z.showQRCode=c.WIFI_SUPPORT_QR_CODE}z.qrcodeSrc="./pic/qrcode_ssid_wifikey.png?_="+d.now();if(z.hasRj45){var o=checkCableMode(e.getOpMode().blc_wan_mode);z.opCurMode=l.observable(o);z.isShowHomeConnect=l.observable(!o);z.showTraffic=l.observable(c.TRAFFIC_SUPPORT&&!o);z.isSupportQuicksetting=l.observable(c.HAS_QUICK_SETTING&&!o)}else{z.isShowHomeConnect=l.observable(true);z.showTraffic=l.observable(c.TRAFFIC_SUPPORT);z.isSupportQuicksetting=l.observable(c.HAS_QUICK_SETTING)}if(c.PRODUCT_TYPE=="DATACARD"){d("#home_image").addClass("data-card")}var q=e.getConnectionInfo();z.networkType=l.observable(k.getNetworkType(q.networkType));z.connectStatus=l.observable(q.connectStatus);z.canConnect=l.observable(false);z.cStatus=l.computed(function(){if(z.connectStatus().indexOf("_connected")!=-1){return i.CONNECTED}else{if(z.connectStatus().indexOf("_disconnecting")!=-1){return i.DISCONNECTING}else{if(z.connectStatus().indexOf("_connecting")!=-1){return i.CONNECTING}else{return i.DISCONNECTED}}}});z.current_Flux=l.observable(transUnit(0,false));z.connected_Time=l.observable(transSecond2Time(0));z.up_Speed=l.observable(transUnit(0,true));z.down_Speed=l.observable(transUnit(0,true));z.isLoggedIn=l.observable(false);z.enableFlag=l.observable(true);z.simSerialNumber=l.observable("");z.imei=l.observable("");z.imsi=l.observable("");z.ssid=l.observable("");z.hasWifi=c.HAS_WIFI;z.showMultiSsid=l.observable(c.HAS_MULTI_SSID&&s.multi_ssid_enable=="1");z.trafficAlertEnable=l.observable(false);z.trafficUsed=l.observable("");z.trafficLimited=l.observable("");z.wireDeviceNum=l.observable(e.getAttachedCableDevices().attachedDevices.length);z.wirelessDeviceNum=l.observable(e.getStatusInfo().wirelessDeviceNum);z.showOpModeWindow=function(){if(z.enableFlag()){return}showSettingWindow("change_mode","opmode/opmode_popup","opmode/opmode_popup",400,300,function(){})};z.currentOpMode=l.observable("0");var u=false;d("#showDetailInfo").popover({html:true,placement:"top",trigger:"focus",title:function(){return d.i18n.prop("device_info")},content:function(){return w("detailInfoTmpl")}}).on("shown.bs.popover",function(){u=true}).on("hidden.bs.popover",function(){u=false});var r=false;d("#showDetailInfo_rtl").popover({html:true,placement:"top",trigger:"focus",title:function(){return d.i18n.prop("device_info")},content:function(){return w("detailInfoTmpl_rtl")}}).on("shown.bs.popover",function(){r=true}).on("hidden.bs.popover",function(){r=false});function x(){var A=e.getDeviceInfo();z.simSerialNumber(verifyDeviceInfo(A.simSerialNumber));z.imei(verifyDeviceInfo(A.imei));z.imsi(verifyDeviceInfo(A.imsi));z.ssid(verifyDeviceInfo(A.ssid));z.showMultiSsid(c.HAS_MULTI_SSID&&A.multi_ssid_enable=="1");return A}x();function w(E){var C=x();k.initShownStatus(C);var A=k.getWanIpAddr(C);var D=_.template(d("#"+E).html());var B=D({simSerialNumber:verifyDeviceInfo(C.simSerialNumber),imei:verifyDeviceInfo(C.imei),imsi:verifyDeviceInfo(C.imsi),sn:verifyDeviceInfo(C.sn),wifi_mac:verifyDeviceInfo(C.wifi_mac),pci:verifyDeviceInfo(C.remo_pci),iccid:verifyDeviceInfo(C.iccid),cellid:verifyDeviceInfo(C.remo_cellid),rsrq:verifyDeviceInfo(C.remo_rsrq),band:verifyDeviceInfo(C.remo_band),rsrp:verifyDeviceInfo(C.remo_rsrp),sinr:verifyDeviceInfo(C.remo_sinr),rssi:verifyDeviceInfo(C.remo_rssi),rscp:verifyDeviceInfo(C.remo_rscp),arfcn:verifyDeviceInfo(C.remo_arfcn),snr:verifyDeviceInfo(C.snr),signal:signalFormat(C.signal),hasWifi:c.HAS_WIFI,isCPE:c.PRODUCT_TYPE=="CPE",hasRj45:c.RJ45_SUPPORT,showMultiSsid:c.HAS_MULTI_SSID&&C.multi_ssid_enable=="1",ssid:verifyDeviceInfo(C.ssid),max_access_num:verifyDeviceInfo(C.max_access_num),m_ssid:verifyDeviceInfo(C.m_ssid),m_max_access_num:verifyDeviceInfo(C.m_max_access_num),wifi_long_mode:"wifi_des_"+C.wifiRange,lanDomain:verifyDeviceInfo(C.lanDomain),ipAddress:verifyDeviceInfo(C.ipAddress),showMacAddress:c.SHOW_MAC_ADDRESS,macAddress:verifyDeviceInfo(C.macAddress),showIpv4WanIpAddr:k.initStatus.showIpv4WanIpAddr,wanIpAddress:A.wanIpAddress,showIpv6WanIpAddr:k.initStatus.showIpv6WanIpAddr,ipv6WanIpAddress:A.ipv6WanIpAddress,sw_version:verifyDeviceInfo(C.sw_version),sale_version:verifyDeviceInfo(C.sales_statistics),show_saleversion:C.show_saleversion=="1",model_id:verifyDeviceInfo(C.model_id),hw_version:verifyDeviceInfo(C.hw_version)});return d(B).translate()}z.connectHandler=function(){if(z.connectStatus()=="ppp_connected"){showLoading("disconnecting");e.disconnect({},function(A){if(A.result){successOverlay()}else{errorOverlay()}})}else{if(e.getStatusInfo().roamingStatus){showConfirm("dial_roaming_connect",function(){z.connect()})}else{z.connect()}}};z.connect=function(){var B=e.getStatusInfo();var C=statusBar.getTrafficResult(B);if(B.limitVolumeEnable&&C.showConfirm){var A=null;if(C.usedPercent>100){A={msg:"traffic_beyond_connect_msg"};statusBar.setTrafficAlertPopuped(true)}else{A={msg:"traffic_limit_connect_msg",params:[C.limitPercent]};statusBar.setTrafficAlert100Popuped(false)}showConfirm(A,function(){k.doConnect()})}else{k.doConnect()}};e.getSignalStrength({},function(B){var A=signalFormat(convertSignal(B));d("#fresh_signal_strength").text(A);d("#fresh_signal_strength_rtl").text(A);if(u){d("#popoverSignalTxt").text(A)}});k.refreshHomeData(z);addInterval(function(){e.getSignalStrength({},function(B){var A=signalFormat(convertSignal(B));d("#fresh_signal_strength").text(A);d("#fresh_signal_strength_rtl").text(A);if(u){d("#popoverSignalTxt").text(A)}});k.refreshHomeData(z)},1000);addInterval(function(){e.get_net_status({},function(B){var A={};A.arfcn=B.remo_arfcn;A.pci=B.remo_pci;A.cellid=B.remo_cellid;A.band=B.remo_band;A.rssi=B.remo_rssi;A.rsrp=B.remo_rsrp;A.sinr=B.remo_sinr;A.rsrq=B.remo_rsrq;A.rscp=B.remo_rscp;if(u){d("#arfcnTxt").text(A.arfcn);d("#pciTxt").text(A.pci);d("#cellidTxt").text(A.cellid);d("#rssiTxt").text(A.rssi);d("#rscpTxt").text(A.rscp);d("#rsrqTxt").text(A.rsrq);d("#bandTxt").text(A.band);d("#rsrpTxt").text(A.rsrp);d("#sinrTxt").text(A.sinr)}})},2000);if(z.hasRj45){k.refreshOpmodeInfo(z);addInterval(function(){k.refreshOpmodeInfo(z)},1000)}z.showNetworkSettingsWindow=function(){if(z.hasRj45){e.getOpMode({},function(A){var B=checkCableMode(A.blc_wan_mode);if(B){window.location.hash="#net_setting"}else{window.location.hash="#dial_setting"}})}else{window.location.hash="#dial_setting"}};var q=e.getLoginData();z.PIN=l.observable();z.PUK=l.observable();z.newPIN=l.observable();z.confirmPIN=l.observable();z.pinNumber=l.observable(q.pinnumber);z.pukNumber=l.observable(q.puknumber);var n=p(q);z.page=l.observable(n);if(n==z.pageState.LOADING){addTimeout(t,500)}z.showOpModeWindow=function(){showSettingWindow("change_mode","opmode/opmode_popup","opmode/opmode_popup",400,300,function(){})};z.isLoggedIn=l.observable(false);z.enableFlag=l.observable(false);z.refreshOpmodeInfo=function(){var B=e.getStatusInfo();z.isLoggedIn(B.isLoggedIn);if(!y&&checkCableMode(B.blc_wan_mode)){if(z.page()==z.pageState.NO_SIM||z.page()==z.pageState.WAIT_PIN||z.page()==z.pageState.WAIT_PUK||z.page()==z.pageState.PUK_LOCKED){window.location.reload()}}y=checkCableMode(B.blc_wan_mode);z.hasParentalControl(c.HAS_PARENTAL_CONTROL&&y);if(y&&B.ethWanMode.toUpperCase()=="DHCP"){z.enableFlag(true)}else{if((!y&&B.connectStatus!="ppp_disconnected")||(y&&B.rj45ConnectStatus!="idle"&&B.rj45ConnectStatus!="dead")){z.enableFlag(false)}else{z.enableFlag(true)}}var C=(B.blc_wan_mode=="AUTO_PPP"||B.blc_wan_mode=="AUTO_PPPOE")?"AUTO":B.blc_wan_mode;var A="";switch(C){case"AUTO":A="opmode_auto";break;case"PPPOE":A="opmode_cable";break;case"PPP":A="opmode_gateway";break;default:break}d("#opmode").attr("data-trans",A).text(d.i18n.prop(A))};if(z.hasRj45){z.refreshOpmodeInfo();addInterval(function(){z.refreshOpmodeInfo()},1000)}z.enterPIN=function(){showLoading();z.page(z.pageState.LOADING);var A=z.PIN();e.enterPIN({PinNumber:A},function(B){if(!B.result){hideLoading();if(z.pinNumber()==2){showAlert("last_enter_pin",function(){t()})}else{showAlert("pin_error",function(){t()})}z.PIN("")}t();if(z.page()==z.pageState.WAIT_PUK){hideLoading()}})};z.enterPUK=function(){showLoading();z.page(z.pageState.LOADING);var C=z.newPIN();var A=z.confirmPIN();var B={};B.PinNumber=C;B.PUKNumber=z.PUK();e.enterPUK(B,function(D){if(!D.result){hideLoading();if(z.pukNumber()==2){showAlert("last_enter_puk",function(){t()})}else{showAlert("puk_error",function(){t();if(z.page()==z.pageState.PUK_LOCKED){hideLoading()}})}z.PUK("");z.newPIN("");z.confirmPIN("")}else{t();if(z.page()==z.pageState.PUK_LOCKED){hideLoading()}}})};function t(){var B=e.getLoginData();var A=p(B);if(A==z.pageState.LOADING){addTimeout(t,500)}else{z.page(A);z.pinNumber(B.pinnumber);z.pukNumber(B.puknumber)}}function p(B){var A=B.modem_main_state;if(A=="modem_sim_undetected"||A=="modem_undetected"||A=="modem_sim_destroy"){return z.pageState.NO_SIM}else{if(d.inArray(A,c.TEMPORARY_MODEM_MAIN_STATE)!=-1){return z.pageState.LOADING}else{if(A=="modem_waitpin"){return z.pageState.WAIT_PIN}else{if((A=="modem_waitpuk"||B.pinnumber==0)&&(B.puknumber!=0)){return z.pageState.WAIT_PUK}else{if((B.puknumber==0||A=="modem_sim_destroy")&&A!="modem_sim_undetected"&&A!="modem_undetected"){return z.pageState.PUK_LOCKED}else{location.reload()}}}}}}}var k={initStatus:null,initShownStatus:function(n){this.initStatus={};var o=n.ipv6PdpType.toLowerCase().indexOf("v6")>0;if(c.RJ45_SUPPORT){var p=checkCableMode(n.blc_wan_mode);if(p){this.initStatus.showIpv6WanIpAddr=false;this.initStatus.showIpv4WanIpAddr=true}else{if(c.IPV6_SUPPORT){if(n.pdpType=="IP"){this.initStatus.showIpv6WanIpAddr=false;this.initStatus.showIpv4WanIpAddr=true}else{if(o){if(n.ipv6PdpType=="IPv6"){this.initStatus.showIpv6WanIpAddr=true;this.initStatus.showIpv4WanIpAddr=false}else{this.initStatus.showIpv6WanIpAddr=true;this.initStatus.showIpv4WanIpAddr=true}}}}else{this.initStatus.showIpv6WanIpAddr=false;this.initStatus.showIpv4WanIpAddr=true}}}else{if(c.IPV6_SUPPORT){if(n.pdpType=="IP"){this.initStatus.showIpv6WanIpAddr=false;this.initStatus.showIpv4WanIpAddr=true}else{if(o){if(n.ipv6PdpType=="IPv6"){this.initStatus.showIpv6WanIpAddr=true;this.initStatus.showIpv4WanIpAddr=false}else{this.initStatus.showIpv6WanIpAddr=true;this.initStatus.showIpv4WanIpAddr=true}}}}else{this.initStatus.showIpv6WanIpAddr=false;this.initStatus.showIpv4WanIpAddr=true}}},getWanIpAddr:function(o){var n={wanIpAddress:"",ipv6WanIpAddress:""};n.wanIpAddress=verifyDeviceInfo(o.wanIpAddress);n.ipv6WanIpAddress=verifyDeviceInfo(o.ipv6WanIpAddress);return n},cachedAPStationBasic:null,cachedConnectionMode:null,getCanConnectNetWork:function(p){var n=e.getStatusInfo();if(n.simStatus!="modem_init_complete"){return false}var o=n.networkType.toLowerCase();if(o=="searching"){return false}if(o==""||o=="limited service"){o="limited_service"}if(o=="no service"){o="no_service"}if(o=="limited_service"||o=="no_service"){if(p.cStatus()!=i.CONNECTED){return false}}if(c.AP_STATION_SUPPORT){if(n.connectWifiStatus=="connect"){if(n.ap_station_mode=="wifi_pref"){return false}}}return true},doConnect:function(){limit_info=e.getDevLimieInfo();if(limit_info.dev_limit!="1"){showLoading("connecting");e.connect({},function(n){if(n.result){successOverlay()}else{errorOverlay()}})}else{showAlert("confirm_limit_warning",function(){showLoading("connecting");e.connect({},function(n){if(n.result){successOverlay()}else{errorOverlay()}})})}},refreshHomeData:function(n){var o=e.getConnectionInfo();n.connectStatus(o.connectStatus);n.canConnect(this.getCanConnectNetWork(n));n.networkType(k.getNetworkType(o.networkType));if(o.connectStatus=="ppp_connected"){n.current_Flux(transUnit(parseInt(o.data_counter.currentReceived,10)+parseInt(o.data_counter.currentSent,10),false));n.connected_Time(transSecond2Time(o.data_counter.currentConnectedTime));n.up_Speed(transUnit(o.data_counter.uploadRate,true));n.down_Speed(transUnit(o.data_counter.downloadRate,true))}else{n.current_Flux(transUnit(0,false));n.connected_Time(transSecond2Time(0));n.up_Speed(transUnit(0,true));n.down_Speed(transUnit(0,true))}n.trafficAlertEnable(o.limitVolumeEnable);if(o.limitVolumeEnable){if(o.limitVolumeType=="1"){n.trafficUsed(transUnit(parseInt(o.data_counter.monthlySent,10)+parseInt(o.data_counter.monthlyReceived,10),false));n.trafficLimited(transUnit(o.limitDataMonth,false))}else{n.trafficUsed(transSecond2Time(o.data_counter.monthlyConnectedTime));n.trafficLimited(transSecond2Time(o.limitTimeMonth))}}if(g!=window.language){g=window.language;b=1}k.refreshStationInfo(n)},getNetworkType:function(o){var n=o.toLowerCase();if(n==""||n=="limited service"){n="limited_service"}if(n=="no service"){n="no_service"}if(n=="limited_service"||n=="no_service"){return d.i18n.prop("network_type_"+n)}else{return o}},refreshStationInfo:function(n){n.wirelessDeviceNum(e.getStatusInfo().wirelessDeviceNum);if(b%10==2){e.getAttachedCableDevices({},function(o){n.wireDeviceNum(o.attachedDevices.length)})}},refreshOpmodeInfo:function(n){var s=e.getOpMode();n.isLoggedIn(s.loginfo=="ok");var r=checkCableMode(s.blc_wan_mode);if(n.opCurMode()&&!r){var q=e.getLoginData();var p=q.modem_main_state;if(p=="modem_sim_undetected"||p=="modem_undetected"||p=="modem_sim_destroy"||p=="modem_waitpin"||p=="modem_waitpuk"||p=="modem_imsi_waitnck"){window.location.reload();return}}n.opCurMode(r);if(r&&s.ethwan_mode=="DHCP"){n.enableFlag(false)}else{if((!r&&s.ppp_status!="ppp_disconnected")||(r&&s.rj45_state!="idle"&&s.rj45_state!="dead")){n.enableFlag(true)}else{n.enableFlag(false)}}var t=(s.blc_wan_mode=="AUTO_PPP"||s.blc_wan_mode=="AUTO_PPPOE")?"AUTO":s.blc_wan_mode;var o="";switch(t){case"AUTO":o="opmode_auto";break;case"PPPOE":o="opmode_cable";break;case"PPP":o="opmode_gateway";break;default:break}d("#opmode").attr("data-trans",o).text(d.i18n.prop(o));n.isShowHomeConnect(!r);n.showTraffic(c.TRAFFIC_SUPPORT&&!r);n.isSupportQuicksetting(c.HAS_QUICK_SETTING&&!r)}};function j(){b=0;k.oldUsedData=null;k.oldAlarmData=null;var n=d("#container")[0];l.cleanNode(n);var o=new a();l.applyBindings(o,n);d("#frmPIN").validate({submitHandler:function(){o.enterPIN()},rules:{txtPIN:"pin_check"}});d("#frmPUK").validate({submitHandler:function(){o.enterPUK()},rules:{txtNewPIN:"pin_check",txtConfirmPIN:{equalToPin:"#txtNewPIN"},txtPUK:"puk_check"}})}return{init:j}});