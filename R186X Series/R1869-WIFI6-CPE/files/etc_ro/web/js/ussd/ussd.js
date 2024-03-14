define(["jquery","service","knockout","config/config"],function(f,i,m,c){var a=true;var e=0;var g=false;var j={SEND:0,REPLY:1};var h;var d=1;var b=0;function k(){var o=this;o.hasUpdateCheck=c.HAS_UPDATE_CHECK;o.ussd_action=m.observable(d);o.USSDLocation=m.observable(j.SEND);o.USSDReply=m.observable("");o.USSDSend=m.observable("");o.hasDdns=c.DDNS_SUPPORT;o.sendToNet=function(){e=0;window.clearInterval(b);var r=o.USSDSend();var p=0;var s;for(p=0;p<r.length;){s=r.charAt(p);if(s==" "){if(r.length>1){r=r.substr(p+1)}else{r="";break}}else{break}}for(p=r.length-1;p>=0&&r.length>0;--p){s=r.charAt(p);if(s==" "){if(r.length>1){r=r.substr(0,p)}else{r="";break}}else{break}}if(("string"!=typeof(r))||(""==r)){showAlert("ussd_error_input");return}showLoading("waiting");var q={};q.operator="ussd_send";q.strUSSDCommand=r;q.sendOrReply="send";i.getUSSDResponse(q,function(t,u){hideLoading();if(t){resetUSSD();o.USSDLocation(j.REPLY);o.ussd_action(u.ussd_action);f("#USSD_Content").val(decodeMessage(u.data,true));g=false;e=0}else{showAlert(u)}})};o.replyToNet=function(){e=0;window.clearInterval(b);var r=o.USSDReply();var p=0;var s;for(p=0;p<r.length;){s=r.charAt(p);if(s==" "){if(r.length>1){r=r.substr(p+1)}else{r="";break}}else{break}}for(p=r.length-1;p>=0&&r.length>0;--p){s=r.charAt(p);if(s==" "){if(r.length>1){r=r.substr(0,p)}else{r="";break}}else{break}}if(("string"!=typeof(r))||(""==r)){showAlert("ussd_error_input");return}showLoading("waiting");var q={};q.operator="ussd_reply";q.strUSSDCommand=r;q.sendOrReply="reply";i.getUSSDResponse(q,function(t,u){hideLoading();if(t){o.ussd_action(u.ussd_action);f("#USSD_Content").val(decodeMessage(u.data,true));g=false;resetUSSD();e=0}else{showAlert(u)}})};o.noReplyCancel=function(){e=0;g=true;window.clearInterval(b);i.USSDReplyCancel(function(p){if(p){resetUSSD();o.USSDLocation(j.SEND)}else{showAlert("ussd_fail")}})};function n(){if(!g){if(e<29){e++}else{g=true;window.clearInterval(b);showAlert("ussd_operation_timeout");o.USSDReply("");o.USSDSend("");o.USSDLocation(j.SEND);e=0}}else{g=true;window.clearInterval(b);e=0}}cancelUSSD=function(){i.USSDReplyCancel(function(p){})};resetUSSD=function(){o.USSDReply("");o.USSDSend("")};if(a){cancelUSSD();a=false}}self.isShowFotaSwitch=m.observable(false);if(i.getfotaswitch().remo_fota_switch=="1"){self.isShowFotaSwitch(true)}else{self.isShowFotaSwitch(false)}function l(){var n=f("#container")[0];m.cleanNode(n);var o=new k();m.applyBindings(o,n)}return{init:l}});