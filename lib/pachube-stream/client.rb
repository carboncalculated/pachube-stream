module PachubeStream
  class Client
        
    # @param [EventMachine::Connection] conn
    # @param [String] api_key
    # @param [Hash] options defaults {}
    def initialize(conn, api_key, options = {})
      @conn = conn
      @api_key = api_key
      @options = options
      @requests = {}
    end
    
    # @param [String] response
    #
    # @return [Hash]
    # @todo refactor ugly as Sin
    def process_data(response)
      parsed_response = parse_response(response)
      status_and_no_ok = parsed_response["status"] && parsed_response["status"] != 200
      if request = @requests[parsed_response["token"]]
        if status_and_no_ok
          call_error_for_request_block(request, parsed_response)
        else
          call_block_for_request(request, parsed_response)
        end
      else
        if status_and_no_ok
          receive_error(parsed_response)
        else
          @conn.on_response_block.call(parsed_response) if @conn.on_response_block 
        end
      end
    end
    
    # @param [String] response
    #
    # @return [Hash]
    def parse_response(response)
      begin
        Yajl::Parser.parse(response)
      rescue Exception => e
        receive_error("#{e.class}: " + [e.message, e.backtrace].flatten.join("\n\t"))
        @conn.close_connection
        return
      end
    end
    
    def receive_error(error)
      @conn.on_error_block.call(error) if @conn.on_error_block
    end
    
    # we send the request and also keep the request with the token
    # as its key so we can attach callback to requests
    def send_request(method, resource, html_request = {}, token = nil, &block)
      @request = Request.new(@api_key, method, resource, html_request, token)
      @requests[@request.token] = @request
      @conn.send_data(@request.to_json)
      @request
    end
            
    # finds the correct callback based on the token which
    # has the method call in its sig
    def call_block_for_request(request, parsed_response)
      if parsed_response["body"].nil?
        request.on_complete_block.call(parsed_response) if request.on_complete_block
      else
       case request.token.gsub(/:.*/, "")
        when "subscribe"
          request.on_datastream_block.call(parsed_response) if request.on_datastream_block
        when "get"
          request.on_get_block.call(parsed_response) if request.on_get_block
        end
      end
    end
    
    def call_error_for_request_block(request, parsed_response)
      request.on_error_block.call(parsed_response) if request.on_error_block
    end
  
  end
end
