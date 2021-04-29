require "clustered_rpc/transport/redis_cluster"
require "shared_functions_helper"

RSpec.describe ClusteredRpc::Transport::RedisCluster do
  context "Using RedisCluster" do
    before(:all) do
      ClusteredRpc.config do |c|
        c.transport_class = ClusteredRpc::Transport::RedisCluster
        c.options = {redis_url: ""}
      end
    end

    before(:each) do 
      if Random.rand > 0.25
        puts "Attempting reconnect"
        ClusteredRpc.reconnect
        puts "Reconnect worked..."
      end
    end

    run_rpc_specs

  end
end