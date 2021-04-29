# ClusteredRpc

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/clustered`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clustered_rpc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clustered_rpc

## Usage

Works on *static* class methods!!!

```ruby
class MyClass
  include ClusteredRpc::Methods

  def self.do_the_thing
    # important code living on many servers in the cluster
    puts "I'm important!"
  end
end

# Run the method on every process running in the cluster
MyClass.clustered_rpc.do_the_thing
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/clustered.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
