---
title: "Back in Time: Time Machine for Ubuntu Linux"
summary: "[Back In Time](http://backintime.le-web.org/) is a great GUI that reproduces the most important OSX Time Machine features: simple graphical configuration and snapshot backups. The current version (0.9.26) is, unfortunately, broken if you want to back up an entire installation. There is a fix, but the developer has not released it yet. Applying the fix yourself is, fortunately, very easy."

tags: 
- back in time
- backintime
- snapshots
- time machine
- ubuntu
categories: 
- Infrastructure
- Disaster Recovery
---

[Back In Time](http://backintime.le-web.org/) is a great GUI that reproduces the most important OSX Time Machine features: simple graphical configuration and snapshot backups. The current version (0.9.26) is, unfortunately, broken if you want to back up an entire installation. There is a fix, but the developer has not released it yet. Applying the fix yourself is, fortunately, very easy.

Follow the directions below to install Back In Time for Ubuntu and backup your entire drive.

## Install Back In Time

Add the following line to your apt sources file (/etc/apt/sources.list)

~~~shell
deb http://le-web.org/repository stable main
~~~

Add the GPG key information:

~~~shell
clc@lurr:~$	wget http://le-web.org/repository/le-web.key
clc@lurr:~$	sudo apt-key add le-web.key
~~~

Install the backintime application for Gnome

~~~shell
clc@lurr:~$	sudo apt-get update
clc@lurr:~$	sudo apt-get install backintime-common backintime-gnome
~~~

Now the default installation of Back In Time should be installed. You can stop here, but if you want to back up your entire drive starting from the root ("/"), you’ll need to install a patch.

## Download and install the patch

~~~shell
clc@lurr:~$ wget http://launchpadlibrarian.net/35340108/snapshots.py.patch
  --2010-03-07 12:28:39--  http://launchpadlibrarian.net/35340108/snapshots.py.patch
  Resolving launchpadlibrarian.net... 91.189.89.228, 91.189.89.229
  Connecting to launchpadlibrarian.net|91.189.89.228|:80... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: 431 [text/plain]
  Saving to: `snapshots.py.patch'
 
  100%[===================================================>] 431      --.-K/s   in 0s      
 
  2010-03-07 12:28:40 (13.9 MB/s) - `snapshots.py.patch' saved [431/431]
 
clc@lurr:~$ sudo patch /usr/share/backintime/common/snapshots.py snapshots.py.patch
  patching file /usr/share/backintime/common/snapshots.py
~~~

Easy as pie. 


## Configure Back In Time

Launch backintime-gnome (assuming your are not using KDE) and configure it.

~~~shell
clc@lurr:~$ sudo backintime-gnome
~~~

Configure where you want the snapshots stored and how often.

![Back In Time Settings - General](/images/blog/backintime/general.png)


Tell backintime which directories you want to save. I’m going for my entire drive starting from the root ("/"). 

![Back In Time Settings: Include](/images/blog/backintime/include.png)

Make sure to tell backintime not to backup special directories as well as the directory you use to store the snapshots. Mine’s under /mnt/backup, so excluding /mnt will get the job done.

![Back In Time Settings: Exclude](/images/blog/backintime/exclude.png)


## Running as Root
If you want to backup your entire drive you’ll need backintime to run as root from root’s crontab. If you run backintime-gnome using sudo from the command line the config file for backintime won’t be saved in root’s .config directory though. When cron calls backintime it will look for the config and won’t find it, so you should create a link to the config file in root’s home directory.

~~~shell
clc@lurr:~$ sudo ln -s ~/.config/backintime/config /home/root/.config/backintime/config
~~~

## Debugging Back In Time
By default the output from Back In Time will be logged to /var/log/syslog. If your snapshots are not being saved as you expect check the syslog log.

~~~shell
clc@lurr:~$ tail -f /var/log/syslog
~~~

I was stymied me for a bit when the cron daemon didn’t seem to be actually running backintime as it should. A quick tail of /var/log/auth.log pointed out that the root account’s password was expired.

~~~shell
clc@lurr:~$ tail -f /var/log/auth.log
~~~

## Optional: Configure Dedicated Logging
By default Back In Time will log its progress to /var/log/syslog. That of course means that every time it runs there will be changes to filesystem, therefore, every time it runs it will need to take a snapshot.

You can configure rsyslogd to push Back In Time’s logs to a dedicated file and then include that file in the exclude list.

Create and edit /etc/rsyslog.d/40-backintime.conf

~~~shell
clc@lurr:~$ vim /etc/rsyslog.d/40-backintime.conf
~~~

Add the following lines

~~~shell
if $programname == 'backintime' then /var/log/backintime.log
if $programname == 'backintime' then ~
~~~

Restart rsyslogd:

~~~shell
clc@lurr:~$ sudo service rsyslog restart
~~~

## Important Note
As of today, March 7th, 2010, the public release of Back In Time [(v0.9.26)](http://backintime.le-web.org/download/backintime/backintime-0.9.26_src.tar.gz) has not been updated to correctly handle taking a snapshot of an entire Ubuntu installation starting from the root directory ("/"). The instructions above are a quick guide for how to correct the issue. Check the [Back In Time download page](http://backintime.le-web.org/download_page/) for the latest version of the application as the public release may have been updated.

## Further Reading
See the [April 15th, 2009 LifeHacker article](http://lifehacker.com/5212899/back-in-time-does-full-linux-backups-in-one-click) for a rundown of the features of Back in Time.

