---
layout: base
---
{% raw %}
<script src="/js/history.js/bundled/html4+html5/native.history.js"></script>
<script src="/js/mustache.js", type="text/javascript"></script>
<script src="/js/flickr-app.js", type="text/javascript"></script>
<script type="text/javascript">
  // @todo - use a  templating library ...
  window.addEvent("domready", function(){
    flickrApp('ffb0f7ab9cfb19fa439130d83570d6d4', '87871204@N00', function(app){
      app.route(window.location.search, true)
    })
  });
</script>

<div id="flickrApp"></div>

<script type="text/html" id="photos-page-tmpl">
  <h2>{{title}}</h2>
  <p style="font-size:10.5pt"> 
  <a href="/photo/?{{resource}}&page={{prev}}" alt="{{title}} page {{prev}}">«</a>
  page {{page}} of {{pages}} 
  <a href="/photo/?{{resource}}&page={{next}}" alt="{{title}} page {{next}}">»</a>
  </p>
  <div id="photo-list"> </div>
</script>

<script type="text/html" id="photo-tmb-tmpl">
  <a href="/photo/?p={{id}}" title="{{title}}" alt="{{title}}">
    <img style="float:left; padding:1em;" src="{{src}}" height="100px" width="100px" alt="{{title}}"/>
  </a>
</script>

<script type="text/html" id="photo-tmpl">
  <h2>{{title}}</h2>
  <a href="{{url}}" title="{{title}}">
    <img style="float:left; padding-right:1em; padding-bottom:2em;" src="{{src}}" height="{{height}}" width="{{width}}" />
  </a>
  <p class="description">{{description}}</p>
  <ul class="tags photo" style="float:left; margin-right:2em; font-size: 10.5pt;">
  Tags:
  {{#tags}}
    <li><a href="/photo?t={{.}}" alt="photos tagged {{.}}">{{.}}</a></li>
  {{/tags}}
  </ul>
</script>

<script type="text/html" id="stream-nav-tmpl">
  <div id="stream-nav" class="navigation" style="width:285px; float:left; font-size:10pt;">
    <div class="alignleft" style="display: inline-block; width:45%;">
      <a href="{{prev.url}}" title="go to {{prev.title}}">
        <img src="{{prev.src}}" height="100px" width="100px" />
        <br />
        < previous
      </a>
    </div> 
    <div class="alignright" style="display: inline-block; width:45%; text-align:right">
      <a href="{{next.url}}" title="go to {{next.title}}">
        <img src="{{next.src}}" height="100px" width="100px" />
        <br />
        next >
      </a>
    </div> 
  </div>
</script>

{% endraw %}
