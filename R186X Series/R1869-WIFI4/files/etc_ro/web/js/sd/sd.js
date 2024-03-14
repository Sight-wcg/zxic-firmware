define(["jquery","config/config","service","knockout"],function(f,c,a,b){var h=c.SD_BASE_PATH;function e(){var i=this;var j=a.getSDConfiguration();i.selectedMode=b.observable(j.sd_mode);i.orignalMode=b.observable(j.sd_mode);i.sdStatus=b.observable(j.sd_status);i.orignalSdStatus=b.observable(j.sd_status);i.sdStatusInfo=b.observable("sd_card_status_info_"+j.sd_status);i.selectedShareEnable=b.observable(j.share_status);i.selectedFileToShare=b.observable(j.file_to_share);i.selectedAccessType=b.observable(j.share_auth);var k=j.share_file.substring(h.length);i.pathToShare=b.observable(k);i.isInvalidPath=b.observable(false);i.checkEnable=b.observable(true);i.disableApplyBtn=b.computed(function(){return i.selectedMode()==i.orignalMode()&&i.selectedMode()=="1"});addInterval(function(){i.checkSimStatus()},3000);i.checkSimStatus=function(){if(i.checkEnable()){var m=a.getSDConfiguration();if(m.sd_status&&(m.sd_status!=i.orignalSdStatus())){if(m.sd_status!="1"){i.sdStatusInfo("sd_card_status_info_"+m.sd_status);i.sdStatus(m.sd_status);i.orignalSdStatus(m.sd_status);f("#sd_card_status_info").translate()}else{clearTimer();clearValidateMsg();g()}}}};i.fileToShareClickHandle=function(){if(i.selectedFileToShare()=="1"){i.pathToShare("/")}return true};i.save=function(){showLoading("waiting");i.checkEnable(false);if(i.orignalMode()==i.selectedMode()){showAlert("setting_no_change")}else{a.setSdCardMode({mode:i.selectedMode()},function(m){if(m.result){i.orignalMode(i.selectedMode());if(m.result=="processing"){errorOverlay("sd_usb_forbidden")}else{successOverlay()}}else{if(i.selectedMode()=="0"){errorOverlay("sd_not_support")}else{errorOverlay()}}},function(m){if(i.selectedMode()=="0"){errorOverlay("sd_not_support")}else{errorOverlay()}})}i.checkEnable(true);return true};i.checkPathIsValid=b.computed(function(){if(i.orignalMode()==0&&i.selectedShareEnable()=="1"&&i.selectedFileToShare()=="0"&&i.pathToShare()!=""&&i.pathToShare()!="/"){a.checkFileExists({path:h+i.pathToShare()},function(m){if(m.status!="exist"){i.isInvalidPath(true)}else{i.isInvalidPath(false)}})}else{i.isInvalidPath(false)}});i.saveShareDetailConfig=function(){showLoading("waiting");i.checkEnable(false);var m={share_status:i.selectedShareEnable(),share_auth:i.selectedAccessType(),share_file:h+i.pathToShare()};if(i.selectedShareEnable()=="0"){l(m)}else{a.checkFileExists({path:m.share_file},function(n){if(n.status!="exist"&&n.status!="processing"){errorOverlay("sd_card_share_setting_"+n.status)}else{l(m)}},function(){errorOverlay()})}i.checkEnable(true);return true};function l(m){a.setSdCardSharing(m,function(n){if(isErrorObject(n)){if(n.errorType=="no_sdcard"){errorOverlay("sd_card_share_setting_no_sdcard")}else{errorOverlay()}}else{successOverlay()}})}}function d(k){var j=[];for(var l=0;l<k.length;l++){j.push(new Option(k.name,k.value))}return j}function g(){var i=f("#container")[0];b.cleanNode(i);var j=new e();b.applyBindings(j,i);f("#sd_card_status_info").translate();f("#sdmode_form").validate({submitHandler:function(){j.save()}});f("#httpshare_form").validate({submitHandler:function(){j.saveShareDetailConfig()},rules:{path_to_share:"check_file_path"}})}return{init:g}});