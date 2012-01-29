var flickrApp = (function(apik, uid, opts, blk){
  if ( !(this instanceof flickrApp) )
    return new flickrApp(apik, uid, blk);

  var FlickrAppError = function(message) {
    this.name = "FlickrAppError";
    this.message = message || "";
  }
  FlickrAppError.prototype = new Error();
  FlickrAppError.prototype.constructor = FlickrAppError;

  var ele;
  var my = this;

  if ((ele = $('flickrApp')) == null)
    throw new FlickrAppError("container element 'flickrApp' not found");

  my.history = [];
  var record_history = function(url){
    my.history.unshift(url);
    History.pushState({router: url}, null, "?" + (url.split('?')[1] || ""))
  }

  var History = window.History;
  History.Adapter.bind(window,'statechange', function(){
       var State = History.getState();
       if(my.history[0] != State.url){
         // user hit the back or forward button
         my.history.shift;
         my.route(State.url); // should this stop history recording?
       }
  });

  /** KERNEL **/
  var merge_opts = function(obj1,obj2){
      var obj3 = {};
      [obj1, obj2].each(function(obj){
        for (var attr in obj) { obj3[attr] = obj[attr]; }
      })
      return obj3;
  }

  var a_find = function(a, cb) {
    var l = a.length;
    for (var i = 0; i < l; i++)
      if(cb(a[i]))
        return a[i];
    return undefined;
  }


  var route = function(params, nohistory){
    console.log("route: ", params);
    if (typeof params == "string") {
      var qa = {};
      nohistory || record_history(params);
      (params.split('?')[1] || "").split("&").each(function(pair){
        pair = pair.split("=")
        qa[pair[0]] = pair[1];
      });
      params = qa;
    } else {
      var qs = [];
      for ( var attr in params) { qs.push(attr + "=" + params[attr]) }
      qs = "?" + qs.join('&')
      nohistory || record_history(qs);
    }

    my.query = params; // let query be accessbile from outside

    ele.empty();
    if (typeof my.query["p"] !== "undefined")
      my.photo(my.query);
    else if(typeof my.query['t'] !== "undefined")
      my.tag(my.query);
    else
      my.recent(my.query);
  }

  var shimLinks = function(){
    ele.getElements('a').each(function(el){
      if (el.get('shimmed')) { return }
      el.removeEvents('click');
      el.addEvent('click', function(e){
        e.stop();
        e.stopPropagation();
        route(el.href);
      });
      el.set("shimmed");
    });
  }



  /** MODEL **/

  // Provides a common model of the FlickrApi
  var flickr = (function(apik, uid){
    var photoCache = {};

    var apiCache = (function(endpnt){
      var cache = {}
      var o_to_qs = function(opts){
        var qs = [];
        for ( var attr in opts) { qs.push(attr + '=' + opts[attr]) }
        return qs = qs.join("&");
      }
      return {
        get : function(meth, opts, cb){
          var furl;
          if(typeof opts === "function"){
            cb = opts;
            furl = endpnt + "&method=" + meth;
          } else {
            furl = endpnt + "&method=" + meth + "&" + o_to_qs(opts);
          }
          console.log("request", furl);
          if (cache[furl] !== undefined) {
            cb(cache[furl]);
          } else  {
            new Request.JSONP({
              url         : furl,
              callbackKey : 'jsoncallback',
              onRequest   : function(url){ console.log("requesting ", furl) },
              onComplete  : function(res){
                cache[furl] = res
                cb(res);
              }
            }).send();
          }
          return apiCache;
        }
      };
    })('http://api.flickr.com/services/rest/?api_key='+apik+'&user_id='+uid+'&format=json');


    return {
      search : (function(per_page){
        return {
          tag : function(tag, opts, cb){
            console.log("requesting photos tagged: " + tag);
            apiCache.get('flickr.photos.search', merge_opts(opts, {'user_id' : uid, 'tags' : tag, per_page : per_page}), cb);
          }
        }
      })(21), // @todo make per_page configurable when starting the app
      recent : function(opts, cb){
        opts = merge_opts({'user_id' : uid, per_page : 21, page : 1 }, opts)
        apiCache.get('flickr.photos.search', opts, cb);
      },
      /* opts:
       *  'thumb': url of photo's thumbnail
       *  'title': title of the photo
       **/
      photo : function(phid, opts){
        if(photoCache[phid])
          return photoCache[phid];
        if(typeof opts === "undefined")
          opts = {};

        photoCache[phid] = {
          id   : phid,
          sizes: function(cb){
            apiCache.get('flickr.photos.getSizes', {photo_id : phid}, cb);
            return photoCache[phid];
          },
          info : function(cb){
            apiCache.get('flickr.photos.getInfo', {photo_id : phid}, cb);
            return photoCache[phid];
          },
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
                sizes.sizes && cb(sizes.sizes.size[1].source);
              });
            }
            return photoCache[phid]
          },
          next : function(cb) {
            apiCache.get('flickr.photos.getContext', {photo_id : phid},  function(context){
              p = context.prevphoto
              cb(flickr.photo(p.id, {'thumb' : p.thumb, 'title' : p.title} ));
            });
            return photoCache[phid];
          },
          prev : function(cb) {
            apiCache.get('flickr.photos.getContext', {photo_id: phid}, function(context){
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
    var p = my.flickr.photo(params['p']);
    p.info(function(info){
      p.sizes(function(sizes){
        // TODO make max width configurable
        var img = a_find(sizes.sizes.size.reverse(), function(size){ return parseInt(size.width) < 550; })
                    || sizes.sizes.size[0];
        if(!img) {
          console.error("couldn't find an appropriate image");
          return;
        };

        view = {
          'title'       : info.photo.title._content,
          'description' : info.photo.description._content,
          'tags'        : info.photo.tags.tag.map(function(tag){return tag.raw}),
          'url'         : 'http://www.flickr.com/photos/'+uid+'/' + params["p"] + '/',
          'src'         : img.source,
          'height'      : img.height,
          'width'       : img.width
        };
        ele.set('html', Mustache.to_html($('photo-tmpl').text, view) + (ele.innerHTML || ""));
        shimLinks();
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
                ele.set('html', (ele.innerHTML || "") + nav );
                shimLinks();
              });
            });
          });
        });
      })
    });
  } // photo

  var tag = function(params){
    my.flickr.search.tag(params['t'], {page : params['page'] || 1}, function(page){
      var view = { title    : 'Photos tagged ' + params['t'],
                   resource : 't=' + params['t'],
                   page     : page.photos.page,
                   pages    : page.photos.pages,
                   next     : page.photos.page + 1 > page.photos.pages ? 1 : page.photos.page + 1,
                   prev     : page.photos.page - 1 < 1 ? page.photos.pages : page.photos.page - 1 };
      ele.set('html', Mustache.to_html($('photos-page-tmpl').text, view))
      var list = $("photo-list");
      page.photos.photo.each(function(photo){
        my.flickr.photo(photo.id, photo.title).thumb(function(thumb){
          view = { title : photo.title, id : photo.id, src : thumb }
          list.set('html', list.innerHTML + Mustache.to_html($('photo-tmb-tmpl').text, view));
          shimLinks();
        });
      });
    })
  }

  var recent = function(params){
    my.flickr.recent({page : params['page'] || 1}, function(page){
      var view = { title    : 'Recent Photos',
                   resource : '',
                   page     : page.photos.page,
                   pages    : page.photos.pages,
                   next     : page.photos.page + 1 > page.photos.pages ? 1 : page.photos.page + 1,
                   prev     : page.photos.page - 1 < 1 ? page.photos.pages : page.photos.page - 1 };
      ele.set('html', Mustache.to_html($('photos-page-tmpl').text, view))
      var list = $("photo-list");
      page.photos.photo.each(function(photo){
        my.flickr.photo(photo.id, photo.title).thumb(function(thumb){
          view = { title : photo.title, id : photo.id, src : thumb }
          list.set('html', list.innerHTML + Mustache.to_html($('photo-tmb-tmpl').text, view));
          shimLinks();
        });
      });
    })
  }


  this.ele    = ele;
  this.flickr = flickr;
  this.route  = route;
  this.query  = '';
  // controllers
  this.photo  = photo;
  this.tag    = tag;
  this.recent = recent;

  typeof blk === "function" && blk(this);
  return this;
});
