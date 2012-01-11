---
title: Attaching to STDERR from EventMachine
---

EventMachine provides popen for running a program and receiving it's output as it runs. Any output written to STDOUT by the program will, unfortunately, not be received by EventMachine. 

Luckily Dane Jensen figured out how to build popen3 for Eventmachine.

{% gist 1333428 %}
