module ClusteredRpc
  module Methods
    extend ActiveSupport::Concern

    included do |base_class|

      def base_class.clustered_rpc(options = {})
        ClusteredRpc::Proxy.new(self, options)
      end

    end

  end
end