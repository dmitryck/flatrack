class Flatrack
  class View
    # Block capture support
    module CaptureHelper
      include ERB::Util

      private

      def capture(*args)
        value  = nil
        buffer = with_output_buffer { value = yield(*args) }
        buffer.presence || value
      end

      # Use an alternate output buffer for the duration of the block.
      # Defaults to a new empty string.
      def with_output_buffer(buf = nil) #:nodoc:
        unless buf
          buf = OutputBuffer.new
          buf.force_encoding(output_buffer.encoding) if output_buffer
        end
        self.output_buffer, old_buffer = buf, output_buffer
        yield
        output_buffer
      ensure
        self.output_buffer = old_buffer
      end
    end
  end
end
