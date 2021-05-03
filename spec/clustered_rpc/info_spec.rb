require 'clustered_rpc/info'

RSpec.describe ClusteredRpc::Info do
  it "ClusteredRpc::Info.stats returns valid information" do
    ClusteredRpc.config {}
    ap ClusteredRpc::Info.stats
  end

  it "ClusteredRpc::Info.clustered_rpc.stats returns valid information" do
    ClusteredRpc.config {}
    ap ClusteredRpc::Info.clustered_rpc.stats(true)
  end

end