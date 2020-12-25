module Clustered
  module Transport
    class Base

      def get_result(request_id)
        raise "Subclassers must implement this to retrieve results"
      end

      def connect
        # Subclassers should implement this
      end

      def subscribed?
        # Subclassers should implement this if they offer keep_alive guarantees
      end

      def reconnect
        # Subclassers should implement this if they offer keep_alive guarantees
      end

      def run_method_from_message(payload)
        klass=payload['klass']
        method=payload['method']
        klass = Object.const_get(klass) rescue nil if klass.is_a? String  
        if klass
          start_time = Time.now
          args = payload['args']
          kwargs = payload['kwargs']
          kwargs = Hash[kwargs.map{|k,v| [k.to_sym, v] }] if kwargs
          result = if args && args.length > 0 && kwargs && kwargs.length > 0
            klass.send method.to_sym, *args, **kwargs
          elsif kwargs && kwargs.length > 0
            klass.send method.to_sym, **kwargs
          elsif args && args.length > 0
            klass.send method.to_sym, *args
          else           
            klass.send method.to_sym
          end          
          seconds = Time.now - start_time        
        end
        {seconds: seconds, result: result}
      end

    end
  end
end