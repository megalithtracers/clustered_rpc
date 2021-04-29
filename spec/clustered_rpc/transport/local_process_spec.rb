require "clustered_rpc/transport/local_process"
require "clustered_rpc/transport/redis_cluster"
require "shared_functions_helper"

RSpec.describe ClusteredRpc::Transport::LocalProcess do
  context "using LocalProcess" do 
    before(:all) do
      ClusteredRpc.config do |c|
        c.transport_class = ClusteredRpc::Transport::LocalProcess
      end
    end

    run_rpc_specs
  end
end