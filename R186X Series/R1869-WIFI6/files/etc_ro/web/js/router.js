define(["config/menu","jquery","config/config","service","underscore"],function(b,f,c,g,i){var e="";var a=f("#container");function j(){m();var n=g.pageIsMobile()?"#home_mobile":"#home";window.location.hash=window.location.hash||n;if(("onhashchange" in window)&&((typeof document.documentMode==="undefined")||document.documentMode==8)){window.onhashchange=h;h()}else{setInterval(h,200)}f("a[href^='#']").die("click").live("click",function(){var o=f(this);c.CONTENT_MODIFIED.checkChangMethod();return checkFormContentModify(o.attr("href"))})}checkFormContentModify=function(n){if(c.CONTENT_MODIFIED.modified&&window.location.hash!=n){if(c.CONTENT_MODIFIED.message=="sms_to_save_draft"){c.CONTENT_MODIFIED.callback.ok(c.CONTENT_MODIFIED.data);c.resetContentModifyValue();window.location.hash=n}else{showConfirm(c.CONTENT_MODIFIED.message,{ok:function(){c.CONTENT_MODIFIED.callback.ok(c.CONTENT_MODIFIED.data);c.resetContentModifyValue();window.location.hash=n},no:function(){var o=c.CONTENT_MODIFIED.callback.no(c.CONTENT_MODIFIED.data);if(!o){window.location.hash=n;c.resetContentModifyValue()}}})}return false}else{return true}};function m(){setInterval(function(){var s=g.getStatusInfo();var n=b.findMenu();if(n.length==0){return false}var r=["phonebook/phonebook","sms/smslist"];var o=(f.inArray(n[0].path,r)!=-1);if(n[0].checkSIMStatus===true){var q=s.simStatus=="modem_sim_undetected"||s.simStatus=="modem_sim_destroy"||s.simStatus=="modem_waitpin"||s.simStatus=="modem_waitpuk";var p=s.simStatus=="modem_imsi_waitnck";if(s.isLoggedIn&&((f("#div-nosimcard")[0]==undefined&&q&&!g.pageIsMobile())||(f("#div-network-lock")[0]==undefined&&p&&!g.pageIsMobile())||((f("#div-nosimcard")[0]!=undefined||f("#div-network-lock")[0]!=undefined)&&s.simStatus=="modem_init_complete")&&!g.pageIsMobile())){d(n[0],s.simStatus,o)}}},1000)}function l(){var o=window.location.hash;if(o=="#login"||i.indexOf(c.GUEST_HASH,o)!=-1){f("#manageContainer").attr("style","margin-top:-36px;")}else{f("#manageContainer").attr("style","margin-top:0px;")}if(window.location.hash=="#login"){f("#mainContainer").addClass("loginBackgroundBlue")}else{var n=f("#mainContainer");if(n.hasClass("loginBackgroundBlue")){f("#container").css({margin:0});n.removeClass("loginBackgroundBlue").height("auto")}}}function h(){if(window.location.hash!=e){var t=g.getStatusInfo();if(window.location.hash==c.defaultRoute||window.location.hash==c.defaultMobileRoute||i.indexOf(c.GUEST_HASH,window.location.hash)!=-1){if(t.isLoggedIn){var p=g.pageIsMobile()?"#home_mobile":"#home";window.location.hash=e==""?p:e;return}}var q=b.findMenu();if(q.length==0){if(g.pageIsMobile()){window.location.hash=c.defaultMobileRoute}else{window.location.hash=c.defaultRoute}}else{if(c.RJ45_SUPPORT&&window.location.hash=="#home"){if((q[0].checkSIMStatus&&checkCableMode(t.blc_wan_mode))||(!q[0].checkSIMStatus&&!checkCableMode(t.blc_wan_mode))){window.location.reload();return}}var n=b.findMenu(e);e=q[0].hash;if(e=="#login"){f("#indexContainer").addClass("login-page-bg");b.rebuild()}else{f("#indexContainer").removeClass("login-page-bg")}if(n.length!=0&&q[0].path==n[0].path&&q[0].level!=n[0].level&&q[0].level!="1"&&n[0].level!="1"){return}l();var s=["phonebook/phonebook","sms/smslist"];var r=(f.inArray(q[0].path,s)!=-1);if(q[0].checkSIMStatus===true||r){if(t.simStatus==undefined){showLoading("waiting");function o(){var u=g.getStatusInfo();if(u.simStatus==undefined||f.inArray(u.simStatus,c.TEMPORARY_MODEM_MAIN_STATE)!=-1){addTimeout(o,500)}else{d(q[0],u.simStatus,r);hideLoading()}}o()}else{d(q[0],t.simStatus,r)}}else{k(q[0])}}}}function d(p,n,o){var q={};f.extend(q,p);if(n=="modem_sim_undetected"||n=="modem_sim_destroy"){if(!o){q.path="nosimcard"}}else{if(n=="modem_waitpin"||n=="modem_waitpuk"){q.path="nosimcard"}else{if(n=="modem_imsi_waitnck"){q.path="network_lock"}}}if(g.pageIsMobile()&&((q.path=="network_lock")||(q.path=="nosimcard"))){q.path="home_mobile";k(q)}else{k(q)}}function k(p){var o=p.path.replace(/\//g,"_");var q=f("body").removeClass();if(g.pageIsMobile()){q.addClass("global")}else{if(o!="login"&&o!="home"){q.addClass("beautiful_bg page_"+o)}else{q.addClass("page_"+o)}}clearTimer();hideLoading();var n="text!tmpl/"+p.path+".html";require([n,p.path],function(r,s){a.stop(true,true);a.hide();a.html(r);s.init();b.refreshMenu();f("#container").translate();b.activeSubMenu();f("form").attr("autocomplete","off");a.fadeIn()})}return{init:j}});