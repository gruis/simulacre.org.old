---
layout: base
---
{% raw %}
<script src="/js/flickr-app.js", type="text/javascript"></script>
<script src="/js/mustache.js", type="text/javascript"></script>
<script type="text/javascript">
  // @todo - use a  templating library ...
  window.addEvent("domready", function(){
    flickrApp('ffb0f7ab9cfb19fa439130d83570d6d4', '87871204@N00', function(app){
      console.log("received");
      console.log(app);
      app.route(app.query); 
    })
  });
</script>

<div id="photo" >

</div>

<script type="text/html" id="photo-tmpl">
  <h2>{{title}}</h2>
  <a href="{{url}}" title="{{title}}">
    <img style="float:left; padding-right:1em;" src="{{src}}" height="{{height}}" width="{{width}}" />
  </a>
  <p>{{description}}
  <ul class="tags photo" style="float:left; margin-right:2em;">
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
