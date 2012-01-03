---
title: Turn LI Elements into Links

categories:
- snippets
tags:
- buttons
- menus
- MooTools
- snippets
- UI
summary: 'Horizontal menus of links [look great](http://www.cssdrive.com/index.php/menudesigns/category/C20/ "horizontal menus") and save space. Building them from UL elements is good practice and makes for [easy CSS styline](http://www.alistapart.com/articles/horizdropdowns/). The LI elements will often contain a link causing them to behave like buttons to trigger a page load.'
---
Horizontal menus of links [look great](http://www.cssdrive.com/index.php/menudesigns/category/C20/ "horizontal menus") and save space. Building them from UL elements is good practice and makes for [easy CSS styline](http://www.alistapart.com/articles/horizdropdowns/). The LI elements will often contain a link causing them to behave like buttons to trigger a page load.

Unfortunately, if the LI elements are setup with a lot of padding there will be a lot of dead space in the button that won't trigger the button's link.

![LI Button Dead Space](http://c5.simulacre.org/blog/images/deadspace.png)

You could make the entire button hot by wrapping the LI element in an anchor tag, but that [wouldn't be valid](http://www.w3.org/TR/html401/struct/global.html#h-7.5.3): block elements should not be contained in inline elements.

### Javascript & MooTools to the Rescue

Put the anchor inside the LI element and use javascript to assign an onClick event to the LI element.

<pre class="js">
  <code class="js">
window.addEvent("domready", function(){
    /** Make LIs into links if necessary. */
   $$(".horiz-nav li").each(function(li){
       var a = li.getFirst("a");
       if(!a) return;
           li.addEvent("click", function(){
               window.location = a.get("href");
           })
   });
});
  </code>
</pre>

