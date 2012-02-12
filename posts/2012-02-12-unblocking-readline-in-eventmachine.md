---
title: Unblocking the Keyboard and Readline in EventMachine
summary: Reading from the keyboard without blocking under EventMachine is pretty simple. Just use the builtin *EM.open_keyboard* and give it a connection handler. If you want to use Readline as well, unfortunately, you'll block the reactor unless you change the behavior of $stdin.
categories:
- Ruby
- EventMachine
tags:
- ruby
- eventmachine
- readline
- keyboard
---

Reading from the keyboard without blocking under EventMachine is pretty
simple. Just use the builtin *EM.open_keyboard* and give it a connection
handler. 

The [Code Snippits Wiki](https://github.com/eventmachine/eventmachine/wiki/Code-Snippets) for EventMachine gives an easy to follow example:

```ruby
require 'eventmachine'
 
module MyKeyboardHandler
  def receive_data keystrokes
    puts "I received the following data from the keyboard: #{keystrokes}"
  end
end

EM.run {
   EM.open_keyboard(MyKeyboardHandler)
}
```


If we want niceties like tab-completion, history, emacs edit mode, etc.,. you're out of luck. Normally you'd just use [readline](http://bogojoker.com/readline/), but it will block. Maybe that's a good thing. Maybe you want the world to stop when asking the human questions. In some situations you don't want to stop the reactor loop though.

The best solution I've come up with is to replace $stdin with an EventMachine keyboard connection and use [RbReadline](https://github.com/luislavena/rb-readline).

{% gist 1806481 nb-keyboard.rb %}

RbReadline defaults to using $stdin for input, so when the NbKeyboard
starts it makes $stdin point to itself. When RbReadline calls *#read(1)*
on $stdin, NbKeyboard gives it back one character if it's available.
Otherwise it pauses the current Fiber until the human types something
in.

The Stlib Readline isn't supported because I haven't found a good way to
get it to read from NbKeyboard rather than STDIN.


To verify that this works just run the demo:
{% gist 1806481 demo.rb %}


```
caleb@kiff % ruby demo.rb
enter something ........ab.cd.ef.g.h.k.li..
you entered: "abcdefghkli"
..
caleb@kiff % 
```

## STDIN Blocking Note

Normally calling STDIN.read_nonblock(1) or STDIN.read(1) will not
return until the user hits enter. The RbReadline and even standard
Readline reset the terminal to not wait for the enter key to be pressed.

If you use EM.open_keyboard without RbReadline attached to it, your
keyboard handler will not receive data until the user presses enter. You
can get around that by using the stty program, or the rb-termios gem to
reconfigure the terminal manually. 
