require 'rubygems'
require "bundler"
Bundler.setup

require "pachube-stream"
Bundler.require(:test)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}


def fixture_path(path)
  File.join(File.dirname(__FILE__), 'fixtures', path)
end

def read_fixture(path)
  File.read(fixture_path(path))
end

Host = "127.0.0.1"
Port = 9550

# == What would be awsome to capture the response tcpdump or something and the replay
class PachubeServer < EM::Connection
  attr_accessor :data
  def receive_data data
    $recieved_data = data
    send_data $data_to_send
    EventMachine.next_tick {
      close_connection if $close_connection
    }
  end
end

def connect_stream(opts={}, &blk)
  EM.run {
    opts.merge!(:host => Host, :port => Port)
    stop_in = opts.delete(:stop_in) || 0.5
    unless opts[:start_server] == false
      EM.start_server Host, Port, PachubeServer
    end
    @stream = PachubeStream::Connection.connect(:api_key => "testing", :host => Host, :port => Port)
    blk.call(@stream) if blk
    EM.add_timer(stop_in){ EM.stop }
  }
end

Rspec.configure do |config|   
  config.mock_with :rspec
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
