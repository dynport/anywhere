# Anywhere

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'anywhere'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install anywhere

## Usage
    pry> require "anywhere/ssh"
    pry> ssh = Anywhere::SSH.new(host = "test.host", user = "root", port: 1234)
    pry> ssh.execute("uptime")
    => <run_time=0.659416, cmd=<uptime>, stdout=<1 lines, 61 chars>, stderr=<empty>, exit_status=0>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
