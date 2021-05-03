# ClusteredRpc
_RPC = Remote Procedure Calls_

[![RubyGems][gem_version_badge]][ruby_gems]
[![Travis CI][travis_ci_badge]][travis_ci]
asdf

ClusteredRpc allows you to run code on every ruby process running within your cluster.

Clusters are defined using a shared pubsub broker and a common namespace.

Currently only Redis PubSub is supported by ClusteredRpc.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clustered_rpc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clustered_rpc

## Configuration
```ruby
# Using Redis PubSub
ClusteredRpc.config do |c|
  c.transport_class = ClusteredRpc::Transport::RedisCluster
  c.cluster_namespace = "myapplication"
  c.options = {redis_url: "redis://127.0.0.1:6379/3"}
end

```
If you are using the same redis server for multiple deployments of your application, then use different namespaces for each.
```ruby
ClusteredRpc.config do |c|
  c.transport_class = ClusteredRpc::Transport::RedisCluster
  # Using the same redis database for the development environment as well...
  c.cluster_namespace = "myapplication_dev"
  c.options = {redis_url: "redis://127.0.0.1:6379/3"}
end
```
## Usage

ClusteredRpc allows static (class) methods to be run on every process within the cluster!

```ruby
class MyClass
  # makes all static-methods available via 'clustered_rpc' proxy method
  include ClusteredRpc::Methods

  def self.do_the_thing
    # important code living on many servers in the cluster
    return "I'm important!"
  end
end

# Run the method on every process running in the cluster
# `do_the_thing` is run on each process and the results are returned in a Hash
MyClass.clustered_rpc.do_the_thing
=> {
    :request_id => "f030b020e058d7a4",
       :success => true,
       :results => {
        "1ca8a7be5e" => {
            "seconds" => 3.3e-05,
             "result" => "I'm important"
        },
        "293a7be9ac" => {
            "seconds" => 4.2e-05,
             "result" => "I'm important"
        }        
    }
}
```
The keys in the results Hash (`1ca8a7be5e` and `293a7be9ac`) are the unique instance_ids assigned to each process by ClusteredRpc

```ruby
# Get the stats for your entire cluster
ClusteredRpc::Info.clustered_rpc.stats
=> { 
  :request_id => "c634e6347b98a0",
     :success => true,
     :results => {
      "ica817be5e" => {
              :instance_id => "1ca8a7be5e",
          :transport_class => "ClusteredRpc::Transport::LocalProcess",
                  :options => {},
               :process_id => 23566,
                   :uptime => "03:14",
                  :used_mb => 35.03,
          :startup_command => "ruby-2.5.1/bin/rails console",
             :process_type => "Rails Console",
              :count_nodes => {}
      },
      {
              :instance_id => "293a7be9ac",
          :transport_class => "ClusteredRpc::Transport::LocalProcess",
                  :options => {},
               :process_id => 23736,
                   :uptime => "42:22",
                  :used_mb => 127.69,
          :startup_command => "ruby-2.5.1/bin/puma",
             :process_type => "Web Server",
              :count_nodes => {}
      }

   }
}

```
Of course, methods can be run locally (without `.clustered_rpc`) as well
```ruby
# Get the stats for the local process
ClusteredRpc::Info.stats
=> {
        :instance_id => "1ca8a7be5e",
    :transport_class => "ClusteredRpc::Transport::LocalProcess",
            :options => {},
         :process_id => 23566,
             :uptime => "00:01",
            :used_mb => 35.03,
    :startup_command => "ruby-2.5.1/bin/rails console",
       :process_type => "Rails Console",
        :count_nodes => {}
}
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/megalithtracers/clustered_rpc.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
