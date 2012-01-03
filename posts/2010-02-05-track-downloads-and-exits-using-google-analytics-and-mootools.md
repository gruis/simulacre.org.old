---
title: Track Downloads and Exits Using Google Analytics and MooTools
categories:
- MooTools
tags: 
- google analytics
- modules
- MooTools
summary: "Last week I recorded [190+ medical engline terminology](http://meditastic.simulacre.org/) audio flashcards for Yoshiko and her classmates at [Nihon University School of Medicine](http://www.med.nihon-u.ac.jp/). They figured that it would be a lot easier to remember the words if they could hear a native speaker pronounce the words and phrases whenever they wanted. That's fine, but I wanted to know when they downloaded the MP3s."
---

[![ExitPoll](http://c5.simulacre.org/exitpoll/images/banner_300x150.png)](http://mootools.net/forge/p/exitpoll)

Last week I recorded [190+ medical engline terminology](http://meditastic.simulacre.org/) audio flashcards for Yoshiko and her classmates at [Nihon University School of Medicine](http://www.med.nihon-u.ac.jp/). They figured that it would be a lot easier to remember the words if they could hear a native speaker pronounce the words and phrases whenever they wanted. That's fine, but I wanted to know when they downloaded the MP3s.

By default Google Analytics won't automatically keep track of file downloads. It's pretty darn easy to do it manually though. Just add an onClick event to the anchor that calls:

<pre>
  <code class="js">
onClick="pageTracker._trackPageview('/download/mp3s.zip');"
  </code>
</pre>

That's pretty easy to do. I could even attach a similar event handler to all the links that lead off of my site, e.g., Twitter, in order to see how people left my site.

So it&#8217;s simple to add an event handler to the outbound links and downloadable files that I want to track, but it&#8217;s just such a pain to remember to add the tracking code every time I add a link. It also makes it a terrible chore if I ever decide to use Googles asynchronous tracking code. I&#8217;d have to go back and change syntax for every single link.

Well, 50 lines of code later I&#8217;ve got a MooTools module, ExitPoll, that tracks every outbound, or download link on a page. It even checks for the type of Analytics that the page is using: synchronous or asynchronous. That&#8217;ll make migrating to asynchronous tracking simple.

![Example Data](http://c5.simulacre.org/exitpoll/images/exampleData_464x215.png)

Anyway, you can download the [latest version of ExitPoll](http://github.com/simulacre/ExitPoll/zipball/master) from [Github](http://github.com/simulacre/ExitPoll).

Just drop the module on your webserver, reference it, and then instantiate ExitPoll in your domready event handler.

<pre>
  <code class="js">
&lt;script src="exitpoll.js" type="text/javascript"&gt;&lt;/script&gt;
&lt;script&gt;
window.addEvent("domready", function(){
   new ExitPoll({ event : "click" });
});
&lt;/script&gt;
  </code>
</pre>

Take a look at the [README](http://github.com/simulacre/ExitPoll/blob/master/README.md) for a full list of available options.
