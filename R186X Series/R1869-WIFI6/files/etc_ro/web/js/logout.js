define(["knockout","service","jquery","config/config","underscore"],function(e,a,g,d,c){function f(){var i=this;var j=b();i.loggedIn=e.observable(j);i.showLogout=function(){if(d.HAS_LOGIN==false){return false}else{return i.loggedIn()}};i.logout=function(){showConfirm("confirm_logout",function(){manualLogout=true;a.logout({},function(){if(a.pageIsMobile()){window.location="index_mobile.html"}else{window.location="index.html"}})})}}function b(){var i=a.getLoginStatus();return(i.status=="loggedIn")}function h(){var i=g("#logout")[0];e.cleanNode(i);e.applyBindings(new f(),i)}return{init:h}});