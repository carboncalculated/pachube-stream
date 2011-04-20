module PachubeStream
  class Connection < EventMachine::Connection
    include RequestMethods
    
    NF_RECONNECT_START = 0.25
    NF_RECONNECT_ADD   = 0.25
    NF_RECONNECT_MAX   = 16
    RECONNECT_MAX   = 320
    RETRIES_MAX     = 10
    
    attr_accessor :options, :on_init_callback, :api_key, :on_response_block, :on_error_block
    attr_accessor :reconnect_callback, :max_reconnects_callback, :nf_last_reconnect, :reconnect_retries
    
    # @todo tidy as crap
    def self.connect(options = {})
      api_key = options[:api_key]
      raise ArgumentError.new("You need to supply an API Key") unless api_key
      host = options[:host] || "beta.pachube.com"
      port = options[:port] || 8081
      EventMachine.connect host, port, self, options
      rescue EventMachine::ConnectionError => e
        conn = EventMachine::FailedConnection.new(req)
        conn.error = e.message
        conn.fail
        conn
    end
    
    def initialize(options)
      @options = options
      @api_key = options[:api_key]
      @timeout = options[:timeout] || 0
      @reconnect_retries = 0
      @immediate_reconnect = false
    end
    
    def client
      @client ||= PachubeStream::Client.new(self, @api_key, @options)
    end
      
    def post_init
      set_comm_inactivity_timeout @timeout if @timeout > 0
      @on_inited_callback.call if @on_inited_callback
    end
        
    def on_reconnect(&block)
      @reconnect_callback = block
    end

    def on_max_reconnects(&block)
      @max_reconnects_callback = block
    end
    
    def on_response_block(&block)
      @on_response_block = block
    end
    
    def on_error_block(&block)
      @on_error_block = block
    end

    def stop
      @gracefully_closed = true
      close_connection
    end

    def immediate_reconnect
      @immediate_reconnect = true
      @gracefully_closed = false
      close_connection
    end

    def unbind
      schedule_reconnect unless @gracefully_closed
    end

    def receive_data(response)
      client.process_data(response)
    end

    protected
    def schedule_reconnect
      timeout = reconnect_timeout
      @reconnect_retries += 1
      if (timeout <= RECONNECT_MAX) && (@reconnect_retries <= RETRIES_MAX)
        reconnect_after(timeout)
      else
        @max_reconnects_callback.call(timeout, @reconnect_retries) if @max_reconnects_callback
      end
    end

    def reconnect_after(timeout)
      @reconnect_callback.call(timeout, @reconnect_retries) if @reconnect_callback

      if timeout == 0
        reconnect @options[:host], @options[:port]
      else
        EventMachine.add_timer(timeout) do
          reconnect @options[:host], @options[:port]
        end
      end
    end

    def reconnect_timeout
      if @immediate_reconnect
        @immediate_reconnect = false
        return 0
      end
      if @nf_last_reconnect
        @nf_last_reconnect += NF_RECONNECT_ADD
      else
        @nf_last_reconnect = NF_RECONNECT_START
      end
      [@nf_last_reconnect, NF_RECONNECT_MAX].min
    end
    
  end
end