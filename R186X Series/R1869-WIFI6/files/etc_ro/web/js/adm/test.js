define(["knockout","service","jquery","config/config","home","opmode/opmode"],function(i,d,c,b,f,g){var e="";function a(){var j=this;j.goformid=i.observable();j.goformidResult=i.observable();j.cmd=i.observable();j.cmdParams=i.observable("");j.goformParams=i.observable("");j.get=function(){var l=c.extend({cmd:j.cmd()},j.parseParams(j.cmdParams()));if(j.cmd().indexOf(",")>=0){l.multi_data=1}var k=d.getNvValue(l);e="";j.showResult(k)};j.set=function(){var k=c.extend({goformId:j.goformid()},j.parseParams(j.goformParams()));d.setGoform(k,function(l){if(l){e="";j.showResult(l)}else{errorOverlay()}})};j.parseParams=function(m){var l=[];if(typeof(m)=="undefined"||m==""){return l}var k=m.split(",");c.each(k,function(n){var p=k[n].indexOf(":");var o=k[n].substring(0,p);var q=k[n].substring(p+1);l[o]=q});return l};j.showResult=function(k){e+="<HR><br>";c.each(k,function(l,m){if(typeof(m)=="object"){j.showResult(m)}else{e+=l+" : "+m+"<br>"}});c("#go").html(e)}}function h(){var j=c("#container")[0];i.cleanNode(j);var k=new a();i.applyBindings(k,j);c("#goformsetForm").validate({submitHandler:function(){k.set()}});c("#nvgetForm").validate({submitHandler:function(){k.get()}})}return{init:h}});