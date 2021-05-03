module ClusteredRpc
  class Proxy 
    def initialize(target, options)
      @target = target
      @options = options
    end

    def method_missing(method, *args, **kwargs)
      wait_seconds = (@options[:wait_seconds] || ENV['CLUSTERED_RPC_WAIT_SECONDS'] || 1.0).to_i
      request_id = ::ClusteredRpc.publish({'klass' => @target.name, 'method' => method, 'args' => args, 'kwargs' => kwargs}.merge(@options))
      {request_id: request_id, success: true, results: ::ClusteredRpc.get_result(request_id, wait_seconds)}
    rescue => e 
      ClusteredRpc.logger.error "ClusteredRpc::Proxy encountered error: #{e.message}"
      {request_id: "Error", success: false, results: e.message}
    end
    
  end
end