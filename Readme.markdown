Icinga REST Gem
===============

A gem to simplify the use of the Icinga REST API.

Currently, the only function that this gem will perform is a count of hosts where a specific service is in a given state. 

e.g. To get a count of all hosts whose names begin with 'web' and whose 'Load' service is critical, you would do this;

    #!/usr/bin/env ruby

    require 'rubygems'
    require 'icinga_rest'

    check = IcingaRest::ServiceCheck.new(
      :host    => 'my.icinga.host',
      :authkey => 'mysecretapikey',
      :filter  => [
        {:host_name    => 'web*'},
        {:service_name => 'Load', :state => :critical}
      ]
    )

    puts check.count

Requirements
------------

You must have enabled the REST API on your Icinga server (and configured the hosts and services to be monitored, of course)

Any box that runs this check will need the wget program in /usr/bin/wget

wget is used instead of a nice ruby http library because the URLs to access the Icinga REST API are not valid http URLs, so all the libraries I tried barf on them. wget is more forgiving.

MIT License
===========

(c) David Salgado 2011, or whenever

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
