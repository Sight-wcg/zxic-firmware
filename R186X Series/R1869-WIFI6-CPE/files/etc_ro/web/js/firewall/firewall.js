define(["jquery","knockout","config/config","service","underscore"],function(e,d,c,a,b){function g(){var h=this;h.hasUssd=c.HAS_USSD;h.hasUrlFilter=c.HAS_URL;h.hasUpdateCheck=c.HAS_UPDATE_CHECK;h.hasDdns=c.DDNS_SUPPORT}function f(){var h=e("#container");d.cleanNode(h[0]);var i=new g();d.applyBindings(i,h[0])}self.isShowFotaSwitch=d.observable(false);if(a.getfotaswitch().remo_fota_switch=="1"){self.isShowFotaSwitch(true)}else{self.isShowFotaSwitch(false)}self.isShowupnpSwitch=d.observable(true);if(a.getupnpswitch().remo_upnp_switch!="0"){self.isShowupnpSwitch(true)}else{self.isShowupnpSwitch(false)}return{init:f}});