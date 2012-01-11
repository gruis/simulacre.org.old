---
title: Making GNU Screen Remember Splits
summary:  '[GNU Screen](http://www.gnu.org/software/screen/) is a great terminal multiplexer or simple window manager for CLI interfaces. Newer versions support spliting a single terminal window both horizontally and vertically. Whenever you detach from a Screen session, any split windows you setup in that session will be lost unless you run nested Screen sessions.'
categories:
- unix
tags:
- linux & unix
- GNU Screen
- cli
- utilities
---

[GNU Screen](http://www.gnu.org/software/screen/) is a great terminal
multiplexer or simple window manager for CLI interfaces. Newer versions
support spliting a single terminal window both horizontally and
vertically. Each split window can run its own independent shell.

![GNU Screen - terminal multiplexer](/images/blog/making-gnu-screen-remember-splits.png)

Screen also allows you to start programs detach from Screen, logout
and later reattach to the same Screen after logging in again. Once
reattached the programs will be safely where they were left.

Unfortunately whenever you detach from a Screen session, any split
windows you setup in that session will be lost. The shells and programs
running in the windows will be fine. You can get them back by recreating
the split windows and connecting each one to a running shell.

That's a real pain though. Future versions of GNU Screen may remember
the split window layouts after reattaching. Until then the only solution
is to use a nested screen session.

Start one Screen session. Then immediately start a second session. Next
reconfigure the escape sequence of the outer session to be *Ctrl-o*. Now
use the standard escape sequence (*Ctrl-a*) to control the second - inner
- session. When you're ready to detach use *Ctrl-o d* instead of *Ctrl-a
  d*. You can safely log out of the terminal now. When you want to get
back just reattach to the first session.


## Example

```shell
# start one Screen session
$ screen -S outer
# start another Screen session in the first session
$ screen -S inner
# reconfigure the control key for the outer Screen
C-a :escape ^Oo

# start top in the inner Screen
$ top
# split the inner Screen and run vmstat in it
C-a S
C-a TAB
C-a C
$ vmstat 2

# detach from the outer Screen
C-o d

# you can logout now

# when ready, reattach to your Screen session
$ screen -ls
There are screens on:
	15615.outer	(Detached)
	15692.inner	(Attached)

$ screen -r outer
```

## Alternate ~/.screenrc
It's worth creating an alternate screenrc file with the escape
keybinding for the outer screen session. Then whenever you start the
outer session just point it at the alternate configuration file.

```shell
$ cat ~/.screenrc.outer                                                                                                                                                                    [master]
escape ^Oo
$ screen -S outer -c ~/.screenrc.outer screen -S inner  
```

## References
 - http://aperiodic.net/screen/quick_reference
 - http://aperiodic.net/screen/faq#when_i_split_the_display_and_then_detach_screen_forgets_the_split
