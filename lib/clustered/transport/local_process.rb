module Clustered
  module Transport
    class LocalProcess < Clustered::Transport::Base


      def publish(payload={})
        result = run_method_from_message(payload)
        Thread.current[:clustered_pass_through_result] = { Clustered.instance_id => result.to_json}
      end

      def get_result(request_id)
        Thread.current[:clustered_pass_through_result]
      end

      def method_missing(method, *args)
        raise "LocalProcess cluster attempted to call missing method [#{method}].  Do you have missing Redis configuration?"
      end
    end
  end
end