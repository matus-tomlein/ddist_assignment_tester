require 'json'

class Connection
  include QueuedListener

  attr_reader :key, :socket

  def initialize(key, socket)
    @key = key
    @socket = socket
  end

  def process_event_now(event)
    json = event.marshal_dump.to_json
    socket.puts json
  end

  def read
    begin
      while socket do
        values = JSON.parse(socket.gets.chop)
        publish_event(OpenStruct.new(values))
      end
    rescue => ex
      puts ex.message
    end
  end

  def disconnect
    clear_listeners
    socket.close
    @socket = nil
  end

  private

  def publish_event(event)
    listeners.each do |listener|
      listener.process_event(event)
    end
  end
end
