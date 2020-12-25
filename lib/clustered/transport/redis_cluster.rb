require 'redis'

module Clustered
  module Transport
    class RedisCluster < Clustered::Transport::Base

      def initialize
        @redis_subscriber = nil
        @redis_publish = nil
        @redis_message_pubsub_key = "__cluster_messages"
        connect
      end

      def publish(payload={})
        @redis_publish.publish @redis_message_pubsub_key, payload.to_json
      rescue => e 
        Clustered.logger.error "Cluster.publish encountered errror: #{e.message}"
        raise e
      end

      def get_result(request_id)
        hgetall("request:#{request_id}")
      end

      def reconnect
        @redis_publish = nil
        if @subscriber_thread
          Clustered.logger.warn "Clustered: killing subscriber thread"
          @subscriber_thread.kill
          @redis_subscriber = nil
        end
        connect
      end

      def hgetall(key_name) 
        @redis_publish.hgetall key_name
      end

      def subscribed?
        @subscribed
      end

      def connect 
        return if !@redis_subscriber.nil? # already connected - call reconnect...
        @redis_subscriber = ::Redis.new(Clustered.options)
        @redis_publish = ::Redis.new(Clustered.options)
        @subscribed = false
        @subscriber_thread = Thread.new do 
          begin
            @redis_subscriber.subscribe( @redis_message_pubsub_key ) do |on|
              on.subscribe do |channel, subscriptions|
                @retry_count = 0
                Clustered.logger.info {"Clustered: Subscribed to ##{channel} (#{subscriptions} subscriptions)"}
                @subscribed = true
              end

              on.message do |channel, message|
                Clustered.logger.debug {"Clustered: Handling message ##{channel}: #{message}"}
                begin
                  message = JSON.parse(message) rescue message
                  if message.is_a? Hash
                    result = run_method_from_message(message)
                    Clustered.logger.debug {"Clustered: Got result: #{result}"}
                    request_id = message['request_id'] 
                    if request_id
                      # Store the result for 10 minutes in hash identified by the request_id and for this particular PID
                      Clustered.logger.debug {"Setting ClusterSend result:  request:#{request_id}[#{Process.pid}]"}
                      @redis_publish.pipelined do 
                        @redis_publish.hmset "request:#{request_id}", Clustered.instance_id, result.to_json
                        @redis_publish.expire "request:#{request_id}", 600
                      end
                    end
                  else
                    Clustered.logger.warn "Unknown message type: #{message.class}"
                  end
                rescue => e
                  Clustered.logger.error e.backtrace.join("\n")
                  Clustered.logger.error "Error[#{e.message}] Handling message ##{channel}: #{message}"
                end
              end

              on.unsubscribe do |channel, subscriptions|
                Clustered.logger.info {"Clustered: Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"}
              end
            end
          rescue Redis::BaseConnectionError => e
            Clustered.logger.error e.message
            @retry_count ||= 0
            @retry_count += 1
            sleep_seconds = [[@retry_count,10].min, 5].max 
            Clustered.logger.warn "Clustered: Retrying redis connection in #{sleep_seconds} seconds: #{@retry_count}"
            Clustered.logger.info @config
            sleep sleep_seconds
            retry if @retry_count <= 300
            Clustered.logger.warn "Clustered: Could not reconnect to Redis"
          ensure
            Clustered.logger.info "Clustered: Subscription thread terminated..."
            @subscribed = false
          end # begin
        end # @subscriber_thread = Thread.new do
        # Give the subscriber a chance to connect in background thread before returning
        attempts = 0
        while !subscribed? do
          sleep(1)
          attempts += 1
          Clustered.logger.info "Clustered: Waiting for subscription...#{attempts} times"
          raise "Clustered: Could not subscribe after #{attempts} attempts" if attempts > 15
        end
      end # def connect
    end # class RedisCluster < Clustered::Transport::Base
  end # module Transport
end # module Clustered