# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Pachube" do
  context "on connection" do
    it "should return stream" do
      EM.should_receive(:connect).and_return('TESTING CONNECT')
      stream = PachubeStream::Connection.connect(:api_key => "Testing")
      stream.should == 'TESTING CONNECT'
    end
    
    it "should define default properties" do
      EM.should_receive(:connect).with do |host, port, handler, opts|
        host.should == 'beta.pachube.com'
        port.should == 8081
      end
      stream = PachubeStream::Connection.connect(:api_key => "Testing")
    end
  end
  
  context "Connection #subscribe" do
    attr_reader :stream
    before(:each) do
      $data_to_send = read_fixture('pachube/subscribe.json')
      $recieved_data = ''
      $close_connection = false
    end
    
    it "should send the 'http_request json request' with the method subscribe'" do
      connect_stream do |connection|
        connection.subscribe("/feeds/100", {}, "token")
      end
      Yajl::Parser.parse($recieved_data).should == Yajl::Parser.parse(read_fixture('pachube/subscribe_request.json'))
    end
    
    it "should capture response to the on_compelete as that is not a datastream response" do
      connect_stream do |connection|
        subscription = connection.subscribe("/feeds/100", {}, "subscribe:a06d6f30-4d78-012e-e33d-002332cf7bbe")
        subscription.on_complete do |response|
          $data_to_send = read_fixture('pachube/subscribe_data_stream.json')
          response.should eq(Yajl::Parser.parse(read_fixture('pachube/subscribe.json')))
        end
      end
    end
    
    it "should send capture response on_datastream for datastream" do
      $data_to_send = read_fixture('pachube/subscribe_data_stream.json')
      connect_stream do |connection|
        subscription = connection.subscribe("/feeds/100", {}, "subscribe:a06d6f30-4d78-012e-e33d-002332cf7bbe")
        subscription.on_datastream do |response|
          response.should eq(Yajl::Parser.parse(read_fixture('pachube/subscribe_data_stream.json')))
        end
      end
    end
    
    it "should capture to the on_error for the request when status code other then 200" do
      $data_to_send = read_fixture('pachube/not_authorized.json')
      connect_stream do |connection|
        subscription = connection.subscribe("/feeds/100", {}, "subscribe:a06d6f30-4d78-012e-e33d-002332cf7bbe")
        subscription.on_error do |response|
          response.should eq(Yajl::Parser.parse(read_fixture('pachube/not_authorized.json')))
        end
      end
    end
  end
  
  context "network failure" do
    before(:each) do
      $close_connection = true
      $data_to_send = ''
    end
    
    it "should reconnect with 0.25 at base"  do
      connect_stream do |connection|
        connection.should_receive(:reconnect_after).with(0.25)
      end
    end
    
    it "should reconnect with linear timeout" do
      connect_stream do |connection|
        connection.nf_last_reconnect = 1
        connection.should_receive(:reconnect_after).with(1.25)
      end
    end
  
    it "should stop reconnecting after 100 times" do
      connect_stream do |connection|
        connection.reconnect_retries = 100
        connection.should_not_receive(:reconnect_after)
      end
    end
  
    it "should notify after reconnect limit is reached" do
      timeout, retries = nil, nil
      connect_stream do |connection|
        connection.on_max_reconnects do |t, r|
          timeout, retries = t, r
        end
        connection.reconnect_retries = 100
      end
      timeout.should == 0.25
      retries.should == 101
    end    
  end

end