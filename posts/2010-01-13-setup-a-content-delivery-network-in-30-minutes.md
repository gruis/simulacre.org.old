---
title: Setup a Content Delivery Network in 30 Minutes
summary: Using a Content Delivery Network will cut down on your hosting fees and improve user experience. Most CDNs are expensive. Building your own is horribly expensive and complicated. Google is cheap and easy, but in a good way.
categories:
- Infrastructure
tags:
- CDN
- Content Delivery Network
- Google App Engine
- notes
---
Using a Content Delivery Network will cut down on your hosting fees and improve user experience. Most CDNs are expensive. Building your own is horribly expensive and complicated. Google is cheap and easy, but in a good way.

<ol>
  <li> Signup for <a title="Google App Engine" href="http://appengine.google.com/">Google App Engine</a> </li>
  <li> <a title="Create GAE application" href="http://appengine.google.com/start/createapp?">Create an app</a> on GAE for your site. <br /> <img src="http://dl.dropbox.com/u/2439349/blog/GAECDN/createAppCheckAvailability.png" /> </li>
  <li> Download the <a href="http://code.google.com/appengine/downloads.html">GAE SDK</a> <br /> <img src="http://dl.dropbox.com/u/2439349/blog/GAECDN/downloadSDK.png" /></li>
  <li> <a href="http://code.google.com/appengine/downloads.html"></a>Create a new application on your development machine <br /> <img src="http://dl.dropbox.com/u/2439349/blog/GAECDN/createLocalApp.png" /> </li>
  <li> Create images, css, and js directories <img src="http://dl.dropbox.com/u/2439349/blog/GAECDN/createLocalDirs.png" /> </li>
  <li> Open up the app.yaml config file and create handles for the images, css, and js directories. The default_expiration tag is optional, but necessary if you want to use <a title="Far-future expiration header for browser caching of static content" href="http://www.askapache.com/htaccess/apache-speed-expires.html">far-future expiration</a> for long-term browser caching.
  <pre class="gae">
  <code class="gae">
application: simulacre-org
version: 1
runtime: python
api_version: 1

default_expiration: "3650d 1h"

handlers:
- url: /css
  static_dir: css

- url: /images
  static_dir: images

- url: /js
  static_dir: js
   </code>
   </pre>
  </li>
<li> Copy all your static content into the images, css and js directories </li>
<li> Deploy the app</span><br /><img src="http://dl.dropbox.com/u/2439349/blog/GAECDN/deployApp.png" /> </li>
<li> Change all static content references on your site to point to http://[appname].appspot.com/ </li>
</ol>

### Optional, but a darn good idea &#8211; Setup a custom domain
1. Setup Google Apps for your domain if you haven't already
2. Login to your hosting environment and add a "static" subdomain CNAME that points to ghts.google.com., e.g., *static.simualcre.org* => ghs.google.com
3. Go back to the GAE Dashboard click on Application Settings then under Domain Setup click on Add Domain ... <br /> ![Add Domain](http://dl.dropbox.com/u/2439349/blog/GAECDN/addDomain.png)
4. Type in the name of your domain, click the add button and you'll be directed to the login for your Google Apps domain
5. Accept the Terms and Conditions
6. Under settings click *Add new URL* and enter the subdomain that you setup in stp 2, e.g., *static*
7. If you haven't already completed step 2, do it now then click *I've completed these steps*
8. Change all static content references on your site to point to your subdomain
9. You're done

Setting up the custom domain is a good idea because if you ever decide to stop using Google App Engine you only need to change the CNAME for the subdomain to point to another server that has the content.

### Caveats & Tools
* While Google App Engine does host your content on multiple servers it does not appear to serve content based on the geographical location of the requester. 
* Use [Watchmouse](http://www.watchmouse.com/en/ping.php "Ping server from many different geographical locations") to figure out if the GAE is serving content based on the requester's geographical location.
* If you like Github give [DryDrop](http://drydrop.binaryage.com/ "Github to Google App Engine") a shot. It pulls your content from Github and pushes it to GAE
