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
    def process_data(response)
      parsed_response = parse_response(response)
      if request = @requests[parsed_response["token"]]
        call_block_for_response(request, parsed_response)
      else
        parsed_response
      end
    end
    
    # @param [String] response
    #
    # @return [Hash]
    def parse_response(response)
      begin
        Yajl::Parser.parse(response)
      rescue Exception => e
        # @todo need to sort it ie for BAD REQUEST AND OTHER HTML alikes
        puts "TODO SORT ME OUT #{response.inspect} ::: #{e.message}"
      end
    end
    
    # we send the request and also keep the request with the token
    # as its key so we can attach callback to requests
    def send_request(method, resource, html_request = {}, &block)
      @request = Request.new(@api_key, method, resource, html_request)
      @requests[@request.token] = @request
      @conn.send_data(@request.to_json)
      @request
    end
    
    # finds the correct callback based on the token which
    # has the method call in its sig
    def call_block_for_response(request, parsed_response)
      case request.token.gsub(/:.*/, "")
      when "subscribe"
        request.on_datastream_block.call(parsed_response) if request.on_datastream_block
      else
        request.on_complete_block.call(parsed_response) if request.on_complete_block
      end
    end
  
  end
end
