module PachubeStream
  module RequestMethods
    
    def get(resource, html_request = {}, &block)
      client.send_request(:get, resource,  html_request = {}, &block)
    end
    
    def post(resource, html_request = {}, &block)
      client.send_request(:post, resource,  html_request = {}, &block)
    end
    
    def put(resource, html_request = {}, &block)
      client.send_request(:put, resource, html_request = {}, &block)
    end
    
    def delete(resource,html_request = {}, &block)
      client.send_request(:delete, resource, html_request = {}, &block)
    end
    
    def subscribe(resource, html_request = {}, &block)
      client.send_request(:subscribe, resource, html_request = {}, &block)
    end
    
    def unsubsribe(resource, html_request = {}, &block)
      client.send_request(:unsubsribe, resource, html_request = {}, &block)
    end

  end
end