require 'json'

class Connection
  include QueuedListener

  attr_reader :key, :socket, :hostname, :listening_port

  def initialize(key, listening_port, socket)
    @key = key
    @listening_port = listening_port
    @hostname = socket.addr.last
    @socket = socket
  end

  def process_event_now(event)
    json = event.marshal_dump.to_json

    begin
      socket.puts json
    rescue => ex
      puts ex.message
      disconnect
    end
  end

  def read
    begin
      while active do
        values = JSON.parse(socket.gets.chop)
        publish_event(OpenStruct.new(values))
      end
    rescue => ex
      puts ex.message
      disconnect
    end
  end

  def disconnect
    clear_listeners
    socket.close if socket
    @socket = nil
  end

  def active
    @socket != nil
  end

  private

  def publish_event(event)
    listeners.each do |listener|
      listener.process_event(event)
    end
  end
end
