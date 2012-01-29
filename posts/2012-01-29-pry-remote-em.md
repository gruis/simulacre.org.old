---
title: Pry Remote for EventMachine
summary: Connect to Pry remotely using EventMachine with tab-completion, paging, user authentication and SSL support.
categories:
- Ruby
- Pry
tags:
- pry
- ruby
- eventmachine
---

[PryRemoteEm](https://rubygems.org/gems/pry-remote-em) enables you to
start instances of Pry in a running
[EventMachine](http://rubyeventmachine.com/) program and connect to
those Pry instances over a network or the Internet. Once connected you
can interact with the internal state of the program.

It's based off of [Mon-Ouie's](https://github.com/Mon-Ouie) [pry-remote](https://github.com/Mon-Ouie/pry-remote) for DRb.

It adds user authentication and SSL support along with tab-completion
and paging. It's compatble with MRI 1.9, or any other VM with support
for Fibers and EventMachine.

It's up on [Github](https://github.com/simulacre/pry-remote-em), so fork
away.


## Installation

```bash
gem install pry-remote-em
```

## Usage

```ruby
require 'pry-remote-em/server'

class Foo
  def initialize(x, y)
    binding.remote_pry_em
  end
end

EM.run { Foo.new 10, 20 } 
```

Running it will print out a message telling you Pry is waiting for a
program to connect itself to it:

```
[pry-remote-em] listening for connections on pryem://localhost:6462/
```

You can then connect to the pry session using *pry-remote-em*:

```ruby
$ pry-remote-em 
[pry-remote-em] client connected to pryem://127.0.0.1:6462/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryem
[1] pry(#<Foo>)> stat 

Method Information:
--
Name: initialize
Owner: Foo
Visibility: private
Type: Bound
Arity: 2
Method Signature: initialize(x, y)
Source Location: (irb):5

[2] pry(#<Foo>)> self
=> #<Foo:0x007fef1b22ac10>

[3] pry(#<Foo>)> ls
locals: _  _dir_  _ex_  _file_  _in_  _out_  _pry_  x  y
[4] pry(#<Foo>)> x
=> 10

[5] pry(#<Foo>)> x = 12
=> 12

[6] pry(#<Foo>)> exit
[pry-remote-em] session terminated

$ pry-remote-em
[pry-remote-em] client connected to pryem://127.0.0.1:6462/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryem
[1] pry(#<Foo>)> x
=> 12

[2] pry(#<Foo>)> exit
[pry-remote-em] session terminated
```

## Features

### Multiple Servers

It's easy to run more than one PryRemoteEm service on a single machine,
or even in the same process. When you start the service via
*#remote_pry_em*, just specify *:auto* as the port to use. The service
will automatically take the next free port from 6462.

```ruby
require "pry-remote-em/server"

os     = ObjectSpace.each_object
expose = []
while expose.length < 5
  o = os.next
  expose.push(o) unless o.frozen?
end

EM.run {
  expose.each {|o| o.remote_pry_em('localhost', :auto) }
}
```

```shell
$ pry-remote-em
[pry-remote-em] client connected to pryem://127.0.0.1:6462/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryem
[1] pry("pretty_print")> 


$ pry-remote-em  pryem://127.0.0.1:6463/
[pry-remote-em] client connected to pryem://127.0.0.1:6463/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryem
[1] pry("pack")> 


$ pry-remote-em  pryem://127.0.0.1:6464/
[pry-remote-em] client connected to pryem://127.0.0.1:6464/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryem
[1] pry("to_json")>


$ pry-remote-em  pryem://127.0.0.1:6465/
[pry-remote-em] client connected to pryem://127.0.0.1:6465/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryem
[1] pry("to_json")> 


$ pry-remote-em  pryem://127.0.0.1:6466/
[pry-remote-em] client connected to pryem://127.0.0.1:6466/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryem
[1] pry(#<RubyVM::InstructionSequence>)> 
```



### TLS Encryption
  
When creating a server pass the :tls => true option to enable TLS. 

```ruby
obj.remote_pry_em('localhost', :auto, :tls => true)
```

If you pass a Hash it will be used to configure the internal TLS handler. 

```ruby
obj.remote_pry_em('localhost', :auto, :tls => {:private_key_file => '/tmp/server.key'})
``` 
See [EventMachine::Connection#start_tls](http://eventmachine.rubyforge.org/EventMachine/Connection.html#M000296) for the available options.


When the command line client connects to a TLS enabled server it will
automatically use TLS mode even if the user didn't request it.

```bash
$ pry-remote-em pryem://localhost:6462/
[pry-remote-em] client connected to pryem://127.0.0.1:6462/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryems
[pry-remote-em] negotiating TLS
[pry-remote-em] TLS connection established
[1] pry(#<Hash>)> 
```

To always require a TLS connection give pry-remote-em a pryem*s* URL. If
the server doesn't support TLS the connection will be terminated.

```bash
$ pry-remote-em pryems://localhost:6468/
[pry-remote-em] client connected to pryem://127.0.0.1:6468/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryem
[pry-remote-em] connection failed
[pry-remote-em] server doesn't support required scheme "pryems"
[pry-remote-em] session terminated
```

### User Authentication

#### Server

 If the service is started with the :auth option it will require all
clients to authenticate on connect. The :auth option can be a Hash, proc
or any object that responds to #call.

##### Auth with a Hash
```ruby
auth_hash = {'caleb' => 'crane', 'john' => 'lowski'}
obj       = {:encoding => __ENCODING__, :weather => :cloudy}
EM.run{
  obj.remote_pry_em('localhost', :auto, :tls => true, :auth => auth_hash)
}
```

##### Auth with a lambda
```ruby
require 'net/ldap'
ldap_anon = lambda do |user, pass|
  ldap = Net::LDAP.new :host => "10.0.0.1", :port => 389, :auth => {:method => :simple, :username => user, :password => pass}
  ldap.bind
end
obj       = {:encoding => __ENCODING__, :weather => :cloudy}
EM.run{
  obj.remote_pry_em('localhost', :auto, :tls => true, :auth => ldap_anon)
}
```

##### Auth with an object
```ruby
class Authenticator
  def initialize(db)
    @db = db
  end
  def call(user, pass)
    @db[user] && @db[user] == pass
  end
end

obj       = {:encoding => __ENCODING__, :weather => :cloudy}
EM.run{
  obj.remote_pry_em('localhost', :auto, :tls => true, :auth => Authenticator.new(auth_hash))
}
```


#### Client

The included command line client *pry-remote-em* can take a username
and/or password as part of the url argument. If either a username or
password is not supplied, but required, by the server, it will prompt for
them.

```shell
$ pry-remote-em pryems://localhost:6464/
[pry-remote-em] client connected to pryem://127.0.0.1:6464/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryems
[pry-remote-em] negotiating TLS
[pry-remote-em] TLS connection established
user: caleb
caleb's password: *****
[1] pry(#<Hash>)> 
```


```shell
$ pry-remote-em pryems://caleb@localhost:6464
[pry-remote-em] client connected to pryem://127.0.0.1:6464/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryems
[pry-remote-em] negotiating TLS
[pry-remote-em] TLS connection established
caleb's password: *****
[1] pry(#<Hash>)> 
```

```shell
$ pry-remote-em pryems://caleb:crane@localhost:6464
[pry-remote-em] client connected to pryem://127.0.0.1:6464/
[pry-remote-em] remote is PryRemoteEm 0.4.0 pryems
[pry-remote-em] negotiating TLS
[pry-remote-em] TLS connection established
[1] pry(#<Hash>)> 
```


### Tab Completion

  Tab completion candidates will be retrieved from the server and
presented on the client side.

```shell
$ bin/pry-remote-em pryems:///
[pry-remote-em] client connected to pryem://127.0.0.1:6462/
[pry-remote-em] remote is PryRemoteEm 0.2.0 pryems
[1] pry(#<Hash>)> key (^TAB ^TAB)
key   key?  keys  
[1] pry(#<Hash>)> keys
=> [:encoding]
```

### Paging

The standard Pry pager is supported through the included client.

```ruby
[1] pry(#<Hash>)> ENV
=> {"COMMAND_MODE"=>"unix2003",
 "DISPLAY"=>"/tmp/launch-0EGhJW/org.x:0",
 "EDITOR"=>"mvim -f --nomru -c \"au VimLeave * !open -a Terminal\"",
 "GEM_HOME"=>"/Users/caleb/.rvm/gems/ruby-1.9.2-p290",
 "GEM_PATH"=>
  "/Users/caleb/.rvm/gems/ruby-1.9.2-p290:/Users/caleb/.rvm/gems/ruby-1.9.2-p290@global",
 "GREP_COLOR"=>"1;32",
 "GREP_OPTIONS"=>"--color=auto",
 "HOME"=>"/Users/caleb",
 "IRBRC"=>"/Users/caleb/.rvm/rubies/ruby-1.9.2-p290/.irbrc",
 "LC_CTYPE"=>"",
 "LOGNAME"=>"caleb",
 "LSCOLORS"=>"Gxfxcxdxbxegedabagacad",
:
```

## Missing Features

  - AutoDiscovery/Broker [ticket](https://github.com/simulacre/pry-remote-em/issues/11)
  - HTTP Transport [ticket](https://github.com/simulacre/pry-remote-em/issues/12)
  - Shell Commands [ticket](https://github.com/simulacre/pry-remote-em/issues/15)
  - Vi mode editing - RbReadline doesn't support vi edit mode. I'm looking into contributing it. PryRemoteEm uses rb-readline because the STLIB version doesn't play nice with Fibers.
  - Ssh key based authentication


## Issues

 Please post any bug reports or feature requests on [Github](https://github.com/simulacre/pry-remote-em/issues)




## Copyright
<pre>
Copyright (c) 2012 Caleb Crane

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be 
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
</pre>
