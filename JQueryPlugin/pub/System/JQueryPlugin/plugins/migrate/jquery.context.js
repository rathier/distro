"use strict";if(jQuery.fn.jquery[0]>=3){var oldInit=jQuery.fn.init;jQuery.fn.init=function(t,e,n){var o;return o=oldInit.apply(this,arguments),t&&void 0!==t.selector?(o.selector=t.selector,o.context=t.context):(o.selector="string"==typeof t?t:"",t&&(o.context=t.nodeType?t:e||document)),o}}