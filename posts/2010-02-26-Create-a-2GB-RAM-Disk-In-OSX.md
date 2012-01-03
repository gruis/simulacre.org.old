---
title: Create a 2GB RAM Disk in OSX
tags: 
- OSX
- ram disk
- sectors
categories: 
- Infrastructure
- snippets
---
<pre>
  <code class="shell">
diskutil erasevolume HFS+ "ramdisk" `hdiutil attach -nomount ram://4194304`
  </code>
</pre>

The only variable is the number of sectors. Calculate it by (size in MB) * 2048
