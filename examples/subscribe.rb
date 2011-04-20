$: << 'lib' << '../lib'
require 'rubygems'
require 'eventmachine'
require '../lib/pachube-stream'

EM.run do
  connection = PachubeStream::Connection.connect(:api_key => ENV["PACHUBE_API_KEY"])
  
  connection.on_reconnect do |timeout, reconnect_retries|
    puts timeout
    puts reconnect_retries
  end
  
  connection.on_max_reconnects do |timeout, reconnect_retries|
    puts timeout
    puts reconnect_retries
  end
  
  feed = connection.subscribe("/feeds/6643") # random Feed  
  
  feed.on_datastream do |response|
    puts response
  end
  
  feed.on_complete do |response|
    puts response
  end
  
  feed.on_error do |response|
    puts response
  end
end