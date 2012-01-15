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
    var furl =  'http://www.flickr.com/photos/'+uid+'/' + params["p"] + '/';
    this.flickr.photo(params["p"]).info(function(info){
      $('photo').getElement('p.desc').set('html', info.photo.description._content);
      info.photo.tags.tag.each(function(tag){
        $('photo').getElement('ul.tags').grab(new Element('li', {'html' : '<a href="/photo/tag/'+tag.raw+'/">'+tag.raw+'</a>'}))
      });
    }).sizes(function(sizes){
      var img = sizes.sizes.size.slice(-1)[0]
      img     = new Element('img', {
        'src'    : img.source,
        'width'  : img.width,
        'height' : img.height,
        'style'  : 'float:left; padding-right:1em;'
      });
      $('photo').grab(new Element('a', { 'href' : furl }).grab(img), 'top');
    }).title(function(title){
      console.log("title: " + title);
    }).next(function(photo){
      console.log("next photo: " + photo.id);
      photo.thumb(function(thumb){
        console.log("  " + photo.id + " : " + thumb);
      }).title(function(title){
        console.log("  " + photo.id + " : " + title);
      });
      console.log();
    }).prev(function(photo){
      console.log("previous photo: " + photo.id);
      photo.thumb(function(thumb){
        console.log("  " + photo.id + " : " + thumb);
      }).title(function(title){
        console.log("  " + photo.id + " : " + title);
      });
    });
  }


  this.photo  = photo;
  this.flickr = flickr;
  this.route  = route;
  this.query  = query;

  typeof blk === "function" && blk(this);
  return this;
});
