---
title: Making GNU Screen Remember Splits
categories:
- snippets
tags:
---

## Example

```shell
$ screen -S outer
$ screen -S inner
C-a :escape ^Oo
$ top
C-a S
C-a TAB
C-a C
$ vmstat 2
C-o d
$ screen -ls
There are screens on:
	15615.outer	(Detached)
	15692.inner	(Attached)
$ screen -r outer
```

## References
 - http://aperiodic.net/screen/quick_reference
 - http://aperiodic.net/screen/quick_reference#escape_key
 - http://aperiodic.net/screen/faq#when_i_split_the_display_and_then_detach_screen_forgets_the_split
