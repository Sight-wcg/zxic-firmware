define(["jquery","lib/jquery/jQuery.fileinput","service","knockout","config/config","status/statusBar"],function(e,k,h,n,b,d){function c(){var o=this;o.hasUssd=b.HAS_USSD;o.hasUpdateCheck=b.HAS_UPDATE_CHECK;o.updateType=n.observable(h.getUpdateType().update_type);o.hasDdns=b.DDNS_SUPPORT;var q=h.getFotaServerInfo();if(q.fota_request_host==q.remo_fota_request_host){o.fota_request_host=n.observable();o.fota_request_port=n.observable()}else{o.fota_request_host=n.observable(q.fota_request_host);o.fota_request_port=n.observable(q.fota_request_port)}var p=h.getOTAUpdateSetting();o.isDataCard=b.PRODUCT_TYPE=="DATACARD";o.updateMode=n.observable(p.updateMode);o.updateIntervalDay=n.observable(p.updateIntervalDay);o.allowRoamingUpdate=n.observable(p.allowRoamingUpdate);o.lastCheckTime=n.observable("");h.getOTAlastCheckTime({},function(r){o.lastCheckTime(r.dm_last_check_time)});o.clickAllowRoamingUpdate=function(){var r=e("#chkUpdateRoamPermission:checked");if(r&&r.length==0){o.allowRoamingUpdate("1")}else{o.allowRoamingUpdate("0")}};o.apply=function(){var r={updateMode:o.updateMode(),updateIntervalDay:o.updateIntervalDay(),allowRoamingUpdate:o.allowRoamingUpdate()};showLoading();h.setOTAUpdateSetting(r,function(s){if(s&&s.result=="success"){p.allowRoamingUpdate=o.allowRoamingUpdate();successOverlay()}else{errorOverlay()}})};o.checkNewVersion=function(){var u=h.getNewVersionState();if(u.fota_package_already_download=="yes"){showAlert("fota_package_already_download");return}if(b.UPGRADE_TYPE=="FOTA"){var t=["checking"];if(e.inArray(u.fota_current_upgrade_state,t)!=-1){showAlert("ota_update_running");return}}var w=h.getStatusInfo();if(u.fota_current_upgrade_state=="prepare_install"){showInfo("ota_download_success");return}var r=["downloading","confirm_dowmload"];if(e.inArray(u.fota_current_upgrade_state,r)!=-1){d.showOTAAlert();return}if(w.roamingStatus){showConfirm("ota_check_roaming_confirm",function(){v()})}else{v()}function v(){showLoading("ota_new_version_checking");function s(){var x=h.getNewVersionState();if(x.hasNewVersion){if(x.fota_new_version_state=="already_has_pkg"&&x.fota_current_upgrade_state!="prepare_install"&&x.fota_current_upgrade_state!="low_battery"){addTimeout(s,1000)}else{d.showOTAAlert()}}else{if(x.fota_new_version_state=="no_new_version"){showAlert("ota_no_new_version")}else{if(x.fota_new_version_state=="check_failed"){errorOverlay("ota_check_fail")}else{if(x.fota_new_version_state=="bad_network"){errorOverlay("ota_connect_server_failed")}else{addTimeout(s,1000)}}}}}h.setUpgradeSelectOp({selectOp:"check"},function(x){if(x.result=="success"){s()}else{errorOverlay()}})}};o.fixPageEnable=function(){var s=h.getStatusInfo();var r=h.getOpMode();if(checkConnectedStatus(s.connectStatus,r.rj45_state,s.connectWifiStatus)){enableBtn(e("#btnCheckNewVersion"))}else{disableBtn(e("#btnCheckNewVersion"))}}}function l(t){var p=0;var q=/msie/i.test(navigator.userAgent)&&!window.opera;if(q){var o=t.value;try{var r=new ActiveXObject("Scripting.FileSystemObject");p=parseInt(r.GetFile(o).size)}catch(s){p=1}}else{try{p=parseInt(t.files[0].size)}catch(s){p=1}}return p/1024/1024}fileUploadSubmitClickHandler=function(){var q=e(".customfile").attr("title");if(typeof q=="undefined"||q==""||q==e.i18n.prop("no_file_selected")){showAlert("sd_no_file_selected");return false}else{var p=q.substring(q.lastIndexOf(".")).toLowerCase();if(!p.match(/.bin/i)){showAlert("error_file_selected");return false}var o=l(e("#fileField")[0]);if(o>b.NATIVE_UPDATE_FILE_SIZE){showAlert("error_file_selected");return false}}showLoading("uploading",'<span data-trans="upload_tip">'+e.i18n.prop("upload_tip")+"</span>");if(!j){i()}e("#fileUploadForm").submit()};function a(r,q,o){if(typeof r=="undefined"||r==""||r==e.i18n.prop("no_file_selected")){showAlert("sd_no_file_selected");return false}var p=r.substring(r.lastIndexOf(".")).toLowerCase();if(!p.match(/.package/i)){showAlert("error_file_selected");return false}if(q.length>=200){showAlert("sd_card_path_too_long");return false}if(o>3){showAlert("ota_file_size_too_big");return false}if(r.indexOf("*")>=0){showAlert("sd_file_name_invalid");return false}return true}updatefileUploadSubmitClickHandler=function(p){if(p){var r=e.trim(e("div#confirm div.promptDiv input#promptInput").val())}else{var r=e(".customfile").attr("title")}console.log("file-name="+r);var q=("/etc_rw/"+r).replace("//","/");var o=l(e("#fileField")[0]);if(-1!=r.indexOf("package")&&!a(r,q,o)){return false}e("#fileUploadForm").attr("action","/remo/ota/"+URLEncodeComponent(r));showLoading("uploading",'<span data-trans="upload_tip">'+e.i18n.prop("upload_tip")+"</span>");if(!j){f()}e("#fileUploadForm").submit()};setFotaHostInfo=function(o){showLoading("waiting");var p={};p.fota_request_host=e("#txtServerHost").val();p.fota_request_port=e("#txtServerPort").val();h.setFotaServerInfo(p,function(q){if(q.result=="1"){successOverlay();setTimeout(function(){showAlert("setsucc_reboot");restartDevice(h)},1000)}else{errorOverlay();window.location.reload()}})};var j=false;function i(){j=true;e("#fileUploadIframe").load(function(){var p=e("#fileUploadIframe").contents().find("body").html().toLowerCase();e("#fileField").closest(".customfile").before('<input id="fileField" name="filename" maxlength="200" type="file" dir="ltr"/>').remove();addTimeout(function(){e("#fileField").customFileInput()},0);var o=false;if(p.indexOf("success")!=-1){showAlert("upload_update_success")}else{if(p.indexOf("failure0")!=-1){showAlert("upload_update_failed0")}else{if(p.indexOf("failure1")!=-1){showAlert("upload_update_failed1")}else{if(p.indexOf("failure2")!=-1){showAlert("upload_update_failed2")}else{if(p.indexOf("failure3")!=-1){showAlert("upload_update_failed3")}else{if(p.indexOf("failure4")!=-1){showAlert("upload_update_failed4")}}}}}}e("#uploadBtn","#uploadSection").attr("data-trans","browse_btn").html(e.i18n.prop("browse_btn"));e(".customfile","#uploadSection").removeAttr("title");e(".customfile span.customfile-feedback","#uploadSection").html('<span data-trans="no_file_selected">'+e.i18n.prop("no_file_selected")+"</span>").attr("class","customfile-feedback")})}function g(){e("#fileField").closest(".customfile").before('<input id="fileField" name="filename" maxlength="200" type="file" dir="ltr"/>').remove();addTimeout(function(){e("#fileField").customFileInput()},0);e("#uploadBtn","#uploadSection").attr("data-trans","browse_btn").html(e.i18n.prop("browse_btn"));e(".customfile","#uploadSection").removeAttr("title");e(".customfile span.customfile-feedback","#uploadSection").html('<span data-trans="no_file_selected">'+e.i18n.prop("no_file_selected")+"</span>").attr("class","customfile-feedback")}function f(){j=true;e("#fileUploadIframe").load(function(){sdIsUploading=false;var p=e("#fileUploadIframe").contents().find("body").html().toLowerCase();console.log("txt:\n"+p);var o=false;if(p.indexOf("ota_success")!=-1){successOverlay();showAlert("ota_succ_reboot")}else{if(p.indexOf("ota_parase_fail")!=-1){o=true;showAlert("ota_parase_fail")}else{if(p.indexOf("ota_verify_fail")!=-1){o=true;showAlert("ota_verify_fail");restartDevice(h)}else{errorOverlay()}}}g()})}function m(){var o=e("#container")[0];n.cleanNode(o);var p=new c();n.applyBindings(p,o);if(p.updateType()=="mifi_fota"){p.fixPageEnable();if(e(".customfile").length==0){e("#fileField").customFileInput()}addInterval(function(){p.fixPageEnable()},1000)}else{if(e(".customfile").length==0){e("#fileField").customFileInput()}}e("#frmOTAUpdate").validate({submitHandler:function(){p.apply()}})}return{init:m}});