module PachubeStream
  class HtmlRequest < Hashie::Dash
  
    property :resource
    property :method
    property :headers, :default => {}
    property :body
    property :params
  
    def api_key=(api_key)
      headers["X-PachubeApiKey"] = api_key
    end
  end
end