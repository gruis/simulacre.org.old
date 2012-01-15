var flickrApp = (function(apik, uid, blk){
  if ( !(this instanceof flickrApp) )
    return new flickrApp(apik, uid, blk);

  /** KERNEL **/
  var query = (function(){
    qa = {}
    window.location.search.slice(1).split("&").each(function(pair){
        pair = pair.split("=");
        qa[pair[0]] = pair[1];
      });
      return qa;
  })();

  var route = function(params){
    if (typeof params["p"] !== "undefined")
      this.photo(params);
    else if(typeof params['t'] !== "undefined")
      this.tag(params);
  }


  /** MODEL **/

  // Provides a common model of the FlickrApi
  var flickr = (function(apik, uid){
    var endpnt     = 'http://api.flickr.com/services/rest/?api_key='+apik+'&user_id='+uid+'&format=json'
    var photoCache = {};
    var get        = function(meth, opts, cb){
      typeof opts === "function" && (cb = opts);
      // @todo check for cb
      return new Request.JSONP({
        url         : endpnt + '&method=' + meth,
        data        : opts,
        callbackKey : 'jsoncallback',
        onRequest   : function(url){ console.log("requesting " + url) },
        onComplete  : cb
      }).send();
    }

    return {
      /* opts:
       *  'thumb': url of photo's thumbnail
       *  'title': title of the photo
       **/
      photo : function(phid, opts){
        if(photoCache[phid])
          return photoCache[phid];
        if(typeof opts === "undefined")
          opts = {};
        var apiCache = (function(){
          var acache = {};
          return {
            // @todo check if a request for the same resource is already
            // running and append to its callback if so.
            get : function(meth, cb) {
              if (typeof acache[meth + phid] !== "undefined"){
                cb(acache[meth + phid]);
              } else {
                get(meth, {'photo_id':phid}, function(ret){
                  acache[meth + phid] = ret;
                  cb(ret);
                });
              }
              return photoCache[phid];
            }
          }
        })();

        photoCache[phid] = {
          id   : phid,
          sizes: function(cb){ return apiCache.get('flickr.photos.getSizes', cb); },
          info : function(cb){ return apiCache.get('flickr.photos.getInfo', cb); },
          title : function(cb) {
            if(opts.title){
              cb(opts.title);
            } else {
              photoCache[phid].info(function(inf){
                cb(inf.photo.title._content);
              });
            }
            return photoCache[phid]
          },
          thumb: function(cb) {
            if(opts.thumb) {
              cb(opts.thumb);
            } else {
              photoCache[phid].sizes(function(sizes){
                // @todo look for the one with the label 'thumbnail'
                cb(sizes.sizes[1].source);
              });
            }
            return photoCache[phid]
          },
          next : function(cb) {
            apiCache.get('flickr.photos.getContext', function(context){
              p = context.prevphoto
              cb(flickr.photo(p.id, {'thumb' : p.thumb, 'title' : p.title} ));
            });
            return photoCache[phid];
          },
          prev : function(cb) {
            apiCache.get('flickr.photos.getContext', function(context){
              p = context.nextphoto
              cb(flickr.photo(p.id, {'thumb' : p.thumb, 'title' : p.title} ));
            });
            return photoCache[phid];
          }
        };
        return photoCache[phid];
      }
    };
  })(apik, uid);


  /** CONTROLLERS **/

  // A specific photo was requested
  // @todo - check for errors
  var photo = function(params){
    var p = this.flickr.photo(params['p']);
    p.info(function(info){
      p.sizes(function(sizes){
        // @todo pick on that is an appropriate size
        var img = sizes.sizes.size.slice(-1)[0];
        view = {
          'title'       : info.photo.title._content,
          'description' : info.photo.description._content,
          'tags'        : info.photo.tags.tag.map(function(tag){return tag.raw}),
          'url'         : 'http://www.flickr.com/photos/'+uid+'/' + params["p"] + '/',
          'src'         : img.source,
          'height'      : img.height,
          'width'       : img.width
        };
        $('photo').set('html', Mustache.to_html($('photo-tmpl').text, view) + ($('photo').innerHTML || ""));
      });
    }).next(function(nextp){
      nextp.thumb(function(nexttmb){
        p.prev(function(prevp){
          prevp.thumb(function(prevtmb){
            prevp.title(function(ptitle){
              nextp.title(function(ntitle){
                var nav = Mustache.to_html($('stream-nav-tmpl').text, {
                  prev : { url: "/photo/?p=" + prevp.id, title: ptitle, src: prevtmb },
                  next : { url: "/photo/?p=" + nextp.id, title: ntitle, src: nexttmb }
                });
                $('photo').set('html', ($('photo').innerHTML || "") + nav );
              });
            });
          });
        });
      })
    });
  } // photo


  this.photo  = photo;
  this.flickr = flickr;
  this.route  = route;
  this.query  = query;

  typeof blk === "function" && blk(this);
  return this;
});
