define(["jquery"],function(b){function c(){b(".statusItem","#statusBar").each(function(d,f){var e=b(this);e.attr("tipTitle",e.attr("title")).removeAttr("title")}).hover(function(){var e=b(this);var f=e.attr("tipTitle");var d=b("<div>").addClass("tooltip in").appendTo(document.body).hide().append(e.attr("i18n")?b.i18n.prop(f):f);if(e.attr("i18n")){d.attr("data-trans",f).attr("id","tooltip_"+e.attr("id"))}var g=a(e,d,{position:["bottom","center"],offset:[0,0]});d.css({position:"absolute",top:g.top,left:g.left}).show()},function(){b(".tooltip").hide().remove()})}function a(f,h,e){var j=f.offset().top,i=f.offset().left,k=e.position[0];j-=h.outerHeight()-e.offset[0];i+=f.outerWidth()+e.offset[1];if(/iPad/i.test(navigator.userAgent)){j-=b(window).scrollTop()}var d=h.outerHeight()+f.outerHeight();if(k=="center"){j+=d/2}if(k=="bottom"){j+=d}k=e.position[1];var g=h.outerWidth()+f.outerWidth();if(k=="center"){i-=g/2}if(k=="left"){i-=g}return{top:j,left:i}}return{init:c}});