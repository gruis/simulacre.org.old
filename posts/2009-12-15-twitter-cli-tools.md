---
title: Twitter Cli Tools
summary: 'Just finished putting a little polish on a few [Twitter command line tools](http://dl.dropbox.com/u/2439349/TwitterCLI.zip) that integrate nicely with GeekTool'
tags:
- cli tools
- geektool
- php
- Twitter
categories:
- Twitter
---
Just finished putting a little polish on a few [Twitter command line tools](http://dl.dropbox.com/u/2439349/TwitterCLI.zip) that integrate nicely with GeekTool

<a href="http://posterous.com/getfile/files.posterous.com/calebcrane/uHujR1P7Dmxxdm42ynoBDIc7gaqULauBvNesztvoRlmIbh0AJDBtlwrqMpdO/Twitter_CLI_Tools_and_GeekTool.png.scaled.1000.jpg">
  <img src="http://posterous.com/getfile/files.posterous.com/calebcrane/KvjMtmGAFScFFj2QhSUJEkohT0tymfzSf1MAgd1uyTauLfi1WBzHDsqWeI3H/Twitter_CLI_Tools_and_GeekTool.png.scaled.500.jpg" alt="Twitter CLI Tools Screenshot" />
</a>

[twitter.php](https://github.com/simulacre/twitter-cli/blob/master/twitter.php) : Pull your friend_timeline from twitter. You can either setup your username and password directly in the script or pass them as command line options.  Run *./twitter.php -h* for a list of all the command line options.

[twitterSearch.php](https://github.com/simulacre/twitter-cli/blob/master/twitterSearch.php) : Search twitter for specific keyword(s). Try *./twitterSearch.php -s* javascript,mootools for most recent posts that contain either the word javascript, or mootools.

[twitterTimeline.php](https://github.com/simulacre/twitter-cli/blob/master/twitterTimeline.php) : Pull a specific user's timeline. I use it to monitor [@ITJobsTweetUS](http://twitter.com/ITJobsTweetUS) without actually following them (they post so much that I loose track of my friend's posts).

Anyway, all the tools integrate well with GeekTool and support a few command line switches. Just run the tool with -h to get a rundown of the options. Only twitter.php requires you to provide a username and password. They all require that you have curl installed and in your path. If you're running OSX you're fine out-of-the-box. Most Linux distros will be fine too. Oh, you'll also need to have php in, or linked from /usr/bin/

[https://github.com/simulacre/twitter-cli](https://github.com/simulacre/twitter-cli)
