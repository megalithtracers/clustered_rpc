require "clustered/transport/redis_cluster"
require "shared_functions_helper"

RSpec.describe Clustered::Transport::RedisCluster do
  context "Using RedisCluster" do
    before(:all) do
      Clustered.config do |c|
        c.transport_class = Clustered::Transport::RedisCluster
        c.options = {redis_url: ""}
      end
    end

    before(:each) do 
      if Random.rand > 0.25
        puts "Attempting reconnect"
        Clustered.reconnect
        puts "Reconnect worked..."
      end
    end

    run_rpc_specs

  end
end