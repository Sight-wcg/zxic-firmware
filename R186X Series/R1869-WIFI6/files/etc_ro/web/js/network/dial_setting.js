define(["jquery","knockout","config/config","service","underscore"],function(e,d,c,a,b){function g(){var k=a.getConnectionMode();var h=this;h.selectMode=d.observable(k.connectionMode);h.enableFlag=d.observable(true);h.isAllowedRoaming=d.observable(k.isAllowedRoaming);var i=k.isAllowedRoaming;h.setAllowedRoaming=function(){if(!e("#roamBtn").hasClass("disable")){var l=e("#isAllowedRoaming:checked");if(l&&l.length==0){h.isAllowedRoaming("on")}else{h.isAllowedRoaming("off")}}};h.save=function(){showLoading();var l=h.selectMode();if(l=="auto_dial"){i=h.isAllowedRoaming()}else{h.isAllowedRoaming(i)}a.setConnectionMode({connectionMode:l,isAllowedRoaming:h.isAllowedRoaming()},function(m){if(m.result=="success"){successOverlay()}else{errorOverlay()}})};var j=e(".checkboxToggle");h.checkEnable=function(){var l=a.getStatusInfo();if(l.connectStatus=="ppp_connected"||l.connectStatus=="ppp_connecting"){h.enableFlag(false);disableCheckbox(j)}else{h.enableFlag(true);enableCheckbox(j)}}}function f(){var h=e("#container");d.cleanNode(h[0]);var i=new g();d.applyBindings(i,h[0]);i.checkEnable();addInterval(i.checkEnable,1000)}return{init:f}});