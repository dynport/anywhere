# Anywhere

Simple wrapper for Net/SSH.

## Installation

Add this line to your application's Gemfile:

    gem 'anywhere'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install anywhere

## Usage

### From ruby
    pry> require "anywhere/ssh"
    pry> ssh = Anywhere::SSH.new(host = "test.host", user = "root", port: 1234)
    pry> ssh.execute("uptime")
    => <run_time=0.659416, cmd=<uptime>, stdout=<1 lines, 61 chars>, stderr=<empty>, exit_status=0>

### From command line

    $ anywhere root@host1 root@host2

    pry> _"uptime"
    2013-06-09T22:35:51.303413Z [host1] DEBUG  00:35:51 up 179 days,  7:48,  0 users,  load average: 0.00, 0.00, 0.00
    2013-06-09T22:35:51.307168Z [host2] DEBUG  22:35:51 up 299 days, 10:49,  0 users,  load average: 0.08, 0.05, 0.06
    => [<run_time=0.06875, cmd=<uptime>, stdout=<1 lines, 72 chars>, stderr=<empty>, exit_status=0>,
     <run_time=0.067885, cmd=<uptime>, stdout=<1 lines, 72 chars>, stderr=<empty>, exit_status=0>]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
