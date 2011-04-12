module PachubeStream
  class Request
    
    attr_accessor :on_complete_block, :on_datastream_block, :request, :token, :method
    
    # @param[String] method
    # @param[String] html this means headers and body and resource and params
    # @param[String] token if you wanted to send a specific token
    def initialize(api_key, method, resource, html_request, token = nil)
      @api_key = api_key
      @method = method
      @resource = resource
      @html_request = html_request
      @token = token || generate_token(method)
      generate_html_request(api_key, method, resource, html_request, @token)
    end
    
    def on_complete(&block)
      @on_complete_block = block
    end
    
    def on_datastream(&block)
      @on_datastream_block = block
    end
    
    def to_json
      @request.to_json
    end
        
    protected 
    def generate_token(method)
      "#{method}:#{UUID.generate}"
    end
    
    def generate_html_request(api_key, method, resource, html_request, token)
      @request = HtmlRequest.new(html_request)
      @request.api_key = api_key
      @request[:method] = method
      @request[:resource] = resource
      @request[:token] = token
    end
  end
end