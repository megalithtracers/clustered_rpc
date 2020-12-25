require "clustered/transport/local_process"
require "clustered/transport/redis_cluster"
require "shared_functions_helper"

RSpec.describe Clustered::Transport::LocalProcess do
  context "using LocalProcess" do 
    before(:all) do
      Clustered.config do |c|
        c.transport_class = Clustered::Transport::LocalProcess
      end
    end

    run_rpc_specs
  end
end