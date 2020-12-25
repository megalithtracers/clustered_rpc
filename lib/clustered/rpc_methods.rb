module Clustered
  module RpcMethods
    extend ActiveSupport::Concern

    included do |base_class|

      def base_class.clustered(options = {})
        Clustered::RpcProxy.new(self, options)
      end

    end

  end
end