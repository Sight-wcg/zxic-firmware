define(["underscore","jquery","knockout","config/config","service"],function(f,b,i,a,d){var c=f.map(a.SMS_VALIDITY,function(j){return new Option(j.name,j.value)});function e(){var j=this;var k=h();j.modes=i.observableArray(c);j.selectedMode=i.observable(k.validity);j.centerNumber=i.observable(k.centerNumber);j.deliveryReport=i.observable(k.deliveryReport);j.clear=function(){g();clearValidateMsg()};j.save=function(){showLoading("waiting");var l={};l.validity=j.selectedMode();l.centerNumber=j.centerNumber();l.deliveryReport=j.deliveryReport();d.setSmsSetting(l,function(m){if(m.result=="success"){successOverlay()}else{errorOverlay()}})}}function h(){return d.getSmsSetting()}function g(){var j=b("#container");i.cleanNode(j[0]);var k=new e();i.applyBindings(k,j[0]);b("#smsSettingForm").validate({submitHandler:function(){k.save()},rules:{txtCenterNumber:"sms_service_center_check"}})}return{init:g}});