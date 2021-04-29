require "clustered_rpc/version"
require "securerandom"
require "logger"
require "json"
require "active_support/concern"
require "clustered_rpc/proxy"
require "clustered_rpc/transport/base"

module ClusteredRpc
  class Error < StandardError; end

  @@instance_id = SecureRandom.hex(5)
  @@logger = ::Logger.new(STDOUT)
  @@transport_class = nil
  @@transport = nil
  @@options = {}

  def self.logger=(logger); @@logger = logger; end
  def self.logger; @@logger; end

  def self.instance_id=(instance_id); @@instance_id = instance_id; end
  def self.instance_id; @@instance_id; end

  def self.transport_class=(transport_class); @@transport_class = transport_class; end
  def self.transport_class; @@transport_class; end

  def self.options=(options); @@options = options; end
  def self.options; @@options; end

  # request_id should have been returned from the call to #cluster_send
  def self.get_result(request_id, wait_seconds = 1.0)
    sleep(wait_seconds) if wait_seconds
    results = @@transport.get_result(request_id)
    results.keys.each{|k| results[k] = JSON.parse(results[k])}
    results # ??? Rails anyone? .with_indifferent_access
  end



  def self.config(force=false, &block)
    block.call(self)

    @@instance_id ||= SecureRandom.hex(5)
    raise "Please set transport_class in ClusteredRpc.config" if transport_class.nil? 
    logger.info "Clustered using #{@@transport_class}"
    @@transport = @@transport_class.new
    @@transport.connect

  end

  def self.reconnect
    @@transport.reconnect
    @@transport
  end

  # payload will likely have keys: [:klass, :method, :args]
  def self.publish(payload={})
    # if :request_id is already present, then we're responding with a process-level response
    # otherwise we're creating a new clustered_request and should generate a :request_io
    payload[:request_id] ||= SecureRandom.hex(8)
    @@transport.publish payload
    payload[:request_id]
  end

end
