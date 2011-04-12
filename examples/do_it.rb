$: << 'lib' << '../lib'
require 'rubygems'
require 'eventmachine'
require '../lib/pachube-stream'

EM.run do
  connection = PachubeStream::Connection.connect(:api_key => ENV["PACHUBE_API_KEY"])
  feed = connection.subscribe("/feeds/12674") # random Feed
  feed.on_datastream do |response|
    puts response
  end
end