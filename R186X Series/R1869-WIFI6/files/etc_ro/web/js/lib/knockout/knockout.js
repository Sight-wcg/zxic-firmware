define(["knockoutbase"],function(a){a.bindingHandlers.slide={update:function(c,d){var e=a.utils.unwrapObservable(d());var b=!(c.style.display=="none");if(e&&!b){$(c).slideDown()}else{if((!e)&&b){$(c).slideUp()}}}};window.ko=a;require(["lib/knockout/knockout.simpleGrid"]);return a});