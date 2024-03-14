define(["jquery","knockout","config/config","service"],function(f,b,o,s){var e=null;var p=200;function q(){return s.getSMSMessages({page:0,smsCount:p,nMessageStoreType:0,tags:10,orderBy:"order by id desc"},function(t){tryToDisableCheckAll(f("#simMsgList-checkAll"),t.messages.length);c(t.messages)},function(t){c([])})}function c(t){f.each(t,function(v,x){x.itemId=getLastNumber(x.number,o.SMS_MATCH_LENGTH);for(var w=0;w<o.phonebook.length;w++){var u=o.phonebook[w];if(x.itemId==getLastNumber(u.pbm_number,o.SMS_MATCH_LENGTH)){x.name=u.pbm_name;break}}});i(t)}cleanSimSmsList=function(){f("#simMsgList_container").empty()};function i(t){if(e==null){e=f.template("simMsgListTmpl",f("#simMsgListTmpl"))}cleanSimSmsList();f("#simMsgList_container").html(f.tmpl("simMsgListTmpl",{data:t}));hideLoading()}function k(t){s.getPhoneBooks({page:0,data_per_page:2000,orderBy:"name",isAsc:true},function(u){if(f.isArray(u.pbm_data)&&u.pbm_data.length>0){o.phonebook=u.pbm_data}else{o.phonebook=[]}t()},function(){errorOverlay()})}function d(){var t=this;g()}deleteSelectedSimMsgClickHandler=function(){var v=f("input[name=msgId]:checked","#simMsgList_container");var t=[];for(var u=0;u<v.length;u++){t.push(f(v[u]).val())}if(t.length==0){return false}showConfirm("confirm_sms_delete",function(){showLoading("deleting");s.deleteMessage({ids:t},function(w){removeChecked("simMsgList-checkAll");disableBtn(f("#simMsgList-delete"));var x="";v.each(function(y,z){x+=".simMsgList-item-class-"+f(z).val()+","});if(x.length>0){f(x.substring(0,x.length-1)).hide().remove()}tryToDisableCheckAll(f("#simMsgList-checkAll"),f(".smslist-item","#simMsgList_container").length);successOverlay()},function(w){errorOverlay(w.errorText)});r(f("#simSmsCapability"))})};function m(){if(n()==0){disableBtn(f("#simMsgList-delete"))}else{enableBtn(f("#simMsgList-delete"))}}function n(){return f("input:checkbox:checked","#simMsgList_container").length}function g(){showLoading("waiting");var t=function(){s.getSMSReady({},function(w){if(w.sms_cmd_status_result=="2"){hideLoading();showAlert("sms_init_fail")}else{if(w.sms_cmd_status_result=="1"){addTimeout(function(){t()},1000)}else{if(!o.HAS_PHONEBOOK){u(o.HAS_PHONEBOOK)}else{v()}}}})};var v=function(){s.getPhoneBookReady({},function(w){if(w.pbm_init_flag=="6"){u(false)}else{if(w.pbm_init_flag!="0"){addTimeout(function(){v()},1000)}else{u(o.HAS_PHONEBOOK)}}})};var u=function(w){if(w){k(function(){q()})}else{o.phonebook=[];q()}};t();h()}function h(){var t=f("#simSmsCapability");r(t);addInterval(function(){r(t)},5000)}function r(t){s.getSmsCapability({},function(u){if(t!=null){t.text("("+u.simUsed+"/"+u.simTotal+")")}})}clearSearchKey=function(){updateSearchValue(f.i18n.prop("search"));f("#searchInput").addClass("ko-grid-search-txt-default").attr("data-trans","search")};searchTextClick=function(){var t=f("#searchInput");if(t.hasClass("ko-grid-search-txt-default")){updateSearchValue("");t.val("");t.removeClass("ko-grid-search-txt-default").removeAttr("data-trans")}};searchTextBlur=function(){var t=f.trim(f("#searchInput").val()).toLowerCase();if(t==""){clearSearchKey()}};updateSearchValue=function(t){if(t==""||t==f.i18n.prop("search")){return true}j(t)};function j(v){v=f.trim(v);var u=f("tr","#smslist-table"),y=u.length;if(v==""){u.show();return false}u.hide();while(y){var w=f(u[y-1]),x=f("td",w),t=x.length;while(t-1){var z=f(x[t-1]);if(z.text().toLowerCase().indexOf(v.toLowerCase())!=-1){w.show();break}t--}y--}addTimeout(function(){f(":checkbox:checked","#addPhonebookContainer").removeAttr("checked");vm.selectedItemIds([]);vm.freshStatus(f.now());renderCheckbox()},300);return true}simsmsItemClickHandler=function(t,w,u){if(t=="1"){var v=[];v.push(w);s.setSmsRead({ids:v},function(x){if(x.result){f(".simMsgList-item-class-"+w,"#simMsgTableContainer").removeClass("font-weight-bold")}})}};function a(){f(".smslist-item-msg","#simMsgTableContainer").die().live("click",function(){var t=f(this).addClass("showFullHeight");f(".smslist-item-msg.showFullHeight","#simMsgTableContainer").not(t).removeClass("showFullHeight")});f("#simMsgList_container p.checkbox, #simMsgListForm #simMsgList-checkAll").die().live("click",function(){m()});f("#searchInput").die().live("blur",function(){searchTextBlur()}).live("keyup",function(){updateSearchValue(f("#searchInput").val())})}function l(){var t=f("#container");b.cleanNode(t[0]);var u=new d();b.applyBindings(u,t[0]);a()}window.smsUtil={changeLocationHandler:function(t){if(f(t).val()=="sim"){window.location.hash="#sim_messages"}else{window.location.hash="#sms"}}};return{init:l}});