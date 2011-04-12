$: << 'lib' << '../lib'
require 'rubygems'
require 'eventmachine'
require '../lib/pachube-stream'

# require "faye"

EM.run do
  # client = Faye::Client.new('http://localhost:9292/faye')
  connection = PachubeStream::Connection.connect(:api_key => ENV["PACHUBE_API_KEY"])
  feed = connection.subscribe("/feeds/6643") # random Feed
  feed.on_datastream do |response|
    puts response
    # client.publish("/messages", response)
  end
end