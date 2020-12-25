require "bundler/setup"
require "clustered"
require "clustered/transport/local_process"
require "byebug"
require "awesome_print"
require "clustered/rpc_methods"

require 'simplecov'
SimpleCov.start

class TestClass
  include Clustered::RpcMethods

  def self.echo_no_args_or_kwargs()
    {}
  end
  def self.echo_args(arg1, arg2)
    { arg1: arg1, arg2: arg2}
  end
  def self.echo_kwargs(kwarg1: , kwarg2: )
    {kwarg1: kwarg1, kwarg2: kwarg2 }
  end
  def self.echo_args_and_kwargs(arg1, arg2, kwarg1: , kwarg2: )
    { arg1: arg1, arg2: arg2, kwarg1: kwarg1, kwarg2: kwarg2 }
  end
end


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end
