(function(){Lighter=new Class({Implements:[Options],name:"Lighter",options:{altLines:"",clipboard:null,container:null,editable:false,flame:"standard",fuel:"standard",id:null,indent:-1,matchType:"standard",mode:"pre",path:null,strict:false},initialize:function(d,c){this.setOptions(c);this.id=this.options.id||this.name+"_"+$time();this.codeblock=$(d);this.container=$(this.options.container);this.code=a(this.codeblock.get("html")).replace(/&lt;/gim,"<").replace(/&gt;/gim,">").replace(/&amp;/gim,"&");if(this.options.indent>-1){this.code=b(this.code,this.options.indent)}this.getPath();this.getClass();this.builder=new Hash({inline:this.createLighter.pass("code",this),pre:this.createLighter.pass("pre",this),ol:this.createLighterWithLines.pass([["ol"],["li"]],this),div:this.createLighterWithLines.pass([["div"],["div","span"],true,"span"],this),table:this.createLighterWithLines.pass([["table","tbody"],["tr","td"],true,"td"],this)});Lighter.scripts=Lighter.scripts||{};Lighter.stylesheets=Lighter.stylesheets||{};this.loadStylesheet(this.options.flame,"Flame."+this.options.flame+".css");this.loadFuel()},loadFuel:function(){try{this.fuel=new Fuel[this.options.fuel](this.code,{matchType:this.options.matchType,strict:this.options.strict});this.light()}catch(c){this.loadScript(this.options.fuel,"Fuel."+this.options.fuel+".js",{load:this.loadFuel.bind(this),error:function(){this.options.fuel="standard";this.loadFuel()}.bind(this)})}},light:function(){this.element=this.toElement();if(this.container){this.container.empty();this.element.inject(this.container)}else{this.codeblock.setStyle("display","none");this.element.inject(this.codeblock,"after");if(this.options.clipboard){this.loadClipboard()}}},unlight:function(){$(this).setStyle("display","none");this.codeblock.setStyle("display","inherit")},loadClipboard:function(){try{var c=new ZeroClipboard.Client();c.setPath(this.options.path);c.glue($(this.options.clipboard));c.setText(this.code);c.addEventListener("complete",function(e,f){alert("Copied text to clipboard:\n"+f)})}catch(d){this.loadScript("clipboard","ZeroClipboard.js",{load:this.loadClipboard.bind(this),error:$empty});return false}},getPath:function(){if(!$chk(Lighter.path)){$$("head script").each(function(d){var c=d.src.split("?",1),e=/Lighter(\.full|\.lite)?\.js$/gi;if(c[0].match(e)){Lighter.path=c[0].replace(e,"")}})}if(!this.options.path){this.options.path=Lighter.path}},getClass:function(){var d=this.codeblock.get("class").split(" "),c=[null,null];switch(d.length){case 0:break;case 1:c=d[0].split(":");break;default:c=d[0].split(":")}if(c[0]){this.options.fuel=c[0]}if(c[1]){this.options.flame=c[1]}},loadScript:function(d,e,c){if($chk(Lighter.scripts[d])){Lighter.scripts[d].addEvents({load:c.load,error:c.error,readystatechange:function(){if(["loaded","complete"].contains(this.readyState)){c.load()}}})}else{Lighter.scripts[d]=new Element("script",{src:this.options.path+e+"?"+$time(),type:"text/javascript",events:{load:c.load,error:c.error,readystatechange:function(){if(["loaded","complete"].contains(this.readyState)){c.load()}}}}).inject(document.head)}},loadStylesheet:function(c,d){if(!$chk(Lighter.stylesheets[c])){Lighter.stylesheets[c]=new Element("link",{rel:"stylesheet",type:"text/css",media:"screen",href:this.options.path+d+"?"+$time()}).inject(document.head)}},createLighter:function(d){var c=new Element(d,{"class":this.options.flame+this.name}),e=0;if(!$defined(this.fuel.wicks[0])){c.appendText(this.code)}else{this.fuel.wicks.each(function(f){c.appendText(this.code.substring(e,f.index));this.insertAndKeepEl(c,f.text,f.type);e=f.index+f.text.length},this);if(e<this.code.length){c.appendText(this.code.substring(e,this.code.length))}}return c},createLighterWithLines:function(k,d,f,e){var m=new Element(k[0],{"class":this.options.flame+this.name,id:this.id}),j=new Element(d[0]),h=1,c=0,l=null;if(k[0]=="table"){m.set("cellpadding",0).set("cellspacing",0).set("border",0)}if(k[1]){m=new Element(k[1]).inject(m)}if(d[1]){j=new Element(d[1]).inject(j)}j.addClass(this.options.flame+"line");if(f){h=this.insertLineNum(j,h,e)}this.fuel.wicks.each(function(n){if(c!=n.index){l=this.code.substring(c,n.index).split("\n");for(var o=0;o<l.length;o++){if(o<l.length-1){if(l[o]===""){l[o]=" "}j=this.insertAndMakeEl(j,m,l[o],d);if(f){h=this.insertLineNum(j,h,e)}}else{this.insertAndKeepEl(j,l[o])}}}l=n.text.split("\n");for(var o=0;o<l.length;o++){if(o<l.length-1){j=this.insertAndMakeEl(j,m,l[o],d,n.type);if(f){h=this.insertLineNum(j,h,e)}}else{this.insertAndKeepEl(j,l[o],n.type)}}c=n.end},this);if(c<=this.code.length){l=this.code.substring(c,this.code.length).split("\n");for(var g=0;g<l.length;g++){j=this.insertAndMakeEl(j,m,l[g],d);if(f){h=this.insertLineNum(j,h,e)}}}if(this.options.altLines!==""){if(this.options.altLines=="hover"){m.getElements("."+this.options.flame+"line").addEvents({mouseover:function(){this.toggleClass("alt")},mouseout:function(){this.toggleClass("alt")}})}else{if(d[1]){m.getChildren(":"+this.options.altLines).getElement("."+this.options.flame+"line").addClass("alt")}else{m.getChildren(":"+this.options.altLines).addClass("alt")}}}if(d[1]){m.getFirst().getChildren().addClass(this.options.flame+"first");m.getLast().getChildren().addClass(this.options.flame+"last")}else{m.getFirst().addClass(this.options.flame+"first");m.getLast().addClass(this.options.flame+"last")}if(k[1]){m=m.getParent()}return m},insertAndKeepEl:function(e,f,c){if(f.length>0){var d=new Element("span",{text:f});if(c){d.addClass(this.fuel.aliases[c]||c)}d.inject(e)}},insertAndMakeEl:function(d,e,f,h,c){this.insertAndKeepEl(d,f,c);if(h[1]){d=d.getParent()}d.inject(e);var g=new Element(h[0]);if(h[1]){g=new Element(h[1]).inject(g)}g.addClass(this.options.flame+"line");return g},insertLineNum:function(d,f,c){var e=new Element(c,{text:f++,"class":this.options.flame+"num"});e.inject(d.getParent(),"top");return f},toElement:function(){if(!this.element){this.element=this.builder[this.options.mode]();if(this.options.editable){this.element.set("contenteditable","true")}}return this.element}});Element.implement({light:function(c){return new Lighter(this,c)}});function a(c){return c.replace(/(^\s*\n|\n\s*$)/gi,"")}function b(f,d){for(var e=0,c="";e<d;e++){c+=" "}return f.replace(/\t/g,c)}})();var Fuel=new Class({Implements:[Options],options:{matchType:"standard",strict:false},language:"",patterns:new Hash(),keywords:new Hash(),delimiters:new Hash({start:null,end:null}),common:{slashComments:/(?:^|[^\\])\/\/.*$/gm,poundComments:/#.*$/gm,multiComments:/\/\*[\s\S]*?\*\//gm,aposStrings:/'[^'\\]*(?:\\.[^'\\]*)*'/gm,quotedStrings:/"[^"\\]*(?:\\.[^"\\]*)*"/gm,multiLineSingleQuotedStrings:/'[^'\\]*(?:\\.[^'\\]*)*'/gm,multiLineDoubleQuotedStrings:/"[^"\\]*(?:\\.[^"\\]*)*"/gm,multiLineStrings:/'[^'\\]*(?:\\.[^'\\]*)*'|"[^"\\]*(?:\\.[^"\\]*)*"/gm,singleQuotedString:/'[^'\\\r\n]*(?:\\.[^'\\\r\n]*)*'/gm,doubleQuotedString:/"[^"\\\r\n]*(?:\\.[^"\\\r\n]*)*"/gm,strings:/'[^'\\\r\n]*(?:\\.[^'\\\r\n]*)*'|"[^"\\\r\n]*(?:\\.[^"\\\r\n]*)*"/gm,properties:/\.([\w]+)\s*/gi,methodCalls:/\.([\w]+)\s*\(/gm,functionCalls:/\b([\w]+)\s*\(/gm,brackets:/\{|\}|\(|\)|\[|\]/g,numbers:/\b((?:(\d+)?\.)?[0-9]+|0x[0-9A-F]+)\b/gi},initialize:function(a,j,i){this.setOptions(j);this.wicks=i||[];this.code=a;this.aliases=$H();this.rules=$H();this.builder=new Hash({standard:this.findMatches,lazy:this.findMatchesLazy});if(!j.strict){if(this.delimiters.start){this.addFuel("delimBeg",this.delimiters.start,"de1")}if(this.delimiters.end){this.addFuel("delimEnd",this.delimiters.end,"de2")}}this.keywords.each(function(l,k){if(l.csv!=""){this.addFuel(k,this.csvToRegExp(l.csv,l.mod||"g"),l.alias)}},this);this.patterns.each(function(k,l){this.addFuel(l,k.pattern,k.alias)},this);var h=0,b=this.code.length,d="",c=this.delimiters,g=[],f=null,e=null;if(!j.strict){g.extend(this.builder[j.matchType].pass(this.code,this)())}else{if(c.start&&c.end){while((f=c.start.exec(this.code))!=null){c.end.lastIndex=c.start.lastIndex;if((e=c.end.exec(this.code))!=null){g.push(new Wick(f[0],"de1",f.index));h=c.start.lastIndex;b=e.index-1;d=this.code.substring(h,b);g.extend(this.builder[j.matchType].pass([d,h],this)());g.push(new Wick(e[0],"de2",e.index))}}}}this.wicks=g},addFuel:function(c,a,b){this.rules[c]=a;this.addAlias(c,b)},addAlias:function(b,a){this.aliases[b]=a||b},csvToRegExp:function(a,b){return new RegExp("\\b("+a.replace(/,\s*/g,"|")+")\\b",b)},delimToRegExp:function(d,b,a,e,f){d=d.escapeRegExp();if(b){b=b.escapeRegExp()}a=(a)?a.escapeRegExp():d;var c=(b)?d+"[^"+a+b+"\\n]*(?:"+b+".[^"+a+b+"\\n]*)*"+a:d+"[^"+a+"\\n]*"+a;return new RegExp(c+(f||""),e||"")},strictRegExp:function(){var b="(";for(var a=0;a<arguments.length;a++){b+=arguments[a].escapeRegExp();b+=(a<arguments.length-1)?"|":""}b+=")";return new RegExp(b,"gim")},findMatches:function(d,f){var b=[],e=0,a=d.length;insertIndex=0,match=null,type=null,newWick=null,rule=null,rules={},currentMatch=null,futureMatch=null;f=f||0;this.rules.each(function(g,h){rules[h]={pattern:g,nextIndex:0}},this);while(e<d.length){a=d.length;match=null;for(rule in rules){rules[rule].pattern.lastIndex=e;currentMatch=rules[rule].pattern.exec(d);if(currentMatch===null){delete rules[rule]}else{if(currentMatch.index<a||(currentMatch.index==a&&match[0].length<currentMatch[0].length)){match=currentMatch;type=rule;a=currentMatch.index}rules[rule].nextIndex=rules[rule].pattern.lastIndex-currentMatch[0].length}}if(match!=null){index=(match[1]&&match[0].contains(match[1]))?match.index+match[0].indexOf(match[1]):match.index;newWick=new Wick(match[1]||match[0],type,index+f);b.push(newWick);futureMatch=rules[type].pattern.exec(d);if(!futureMatch){rules[type].nextIndex=d.length}else{rules[type].nextIndex=rules[type].pattern.lastIndex-futureMatch[0].length}var c=d.length;for(rule in rules){if(rules[rule].nextIndex<c){c=rules[rule].nextIndex}}e=Math.max(c,newWick.end-f)}else{break}}return b},findMatchesLazy:function(c,d){var a=this.wicks,b=null;index=0;d=d||0;this.rules.each(function(e,f){while((b=e.exec(c))!=null){index=(b[1]&&b[0].contains(b[1]))?b.index+b[0].indexOf(b[1]):b.index;a.push(new Wick(b[1]||b[0],f,index+d))}},this);return this.purgeWicks(a)},purgeWicks:function(a){a=a.sort(this.compareWicks);for(var c=0,b=0;c<a.length;c++){if(a[c]==null){continue}for(b=c+1;b<a.length&&a[c]!=null;b++){if(a[b]==null){continue}else{if(a[b].isBeyond(a[c])){break}else{if(a[b].overlaps(a[c])){a[c]=null}else{if(a[c].contains(a[b])){a[b]=null}}}}}}return a.clean()},compareWicks:function(b,a){return b.index-a.index}});Fuel.standard=new Class({Extends:Fuel,initialize:function(c,b,a){this.parent(c,b,a)}});var Wick=new Class({initialize:function(b,c,a){this.text=b;this.type=c;this.index=a;this.length=this.text.length;this.end=this.index+this.length},contains:function(a){return(a.index>=this.index&&a.index<this.end)},isBeyond:function(a){return(this.index>=a.end)},overlaps:function(a){return(this.index==a.index&&this.length>a.length)},toString:function(){return this.index+" - "+this.text+" - "+this.end}});
