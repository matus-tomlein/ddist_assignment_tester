require 'socket'

class AppController
  attr_reader :editor

  def initialize
    @editor = Editor.new
    @connections = []
  end

  def text_area
    @text_area ||= TextArea.new.init(editor)
  end

  def listen(port)
    @listening_port = port
    disconnect
    Thread.new do
      @server = TCPServer.open(port)
      loop do
        Thread.start(@server.accept) do |socket|
          begin
            # exchange keys
            hello = JSON.parse(socket.gets.chop)
            socket.puts(hello_message(hello['initialize']))

            start_connection hello, socket
          rescue => e
            puts e.message
            puts e.backtrace.join("\n")
          end
        end
      end
    end
  end

  def connect(host, port, initialize = true)
    if initialize
      disconnect

      @listening_port = 2000 + rand(9999)
      listen @listening_port
    end

    Thread.start(TCPSocket.open(host, port)) do |socket|
      begin
        # exchange keys
        socket.puts(hello_message(initialize))
        hello = JSON.parse(socket.gets.chop)

        start_connection hello, socket
      rescue => e
        puts e.message
        puts e.backtrace.join("\n")
      end
    end
  end

  def disconnect
    @connections.each do |connection|
      connection.disconnect
    end
    @connections = []

    if @server
      @server.close
      @server = nil
    end
  end

  def hello_message(initialize)
    {
      'key' => editor.key,
      'port' => @listening_port,
      'initialize' => initialize,
      'connections' => active_connections.map do |c|
        { 'key' => c.key, 'hostname' => c.hostname, 'port' => c.listening_port }
      end
    }.to_json
  end

  def active_connections
    @connections.find_all do |connection|
      connection.active
    end
  end

  private

  def start_connection(hello, socket)
    connection = Connection.new(hello['key'], hello['port'], socket)
    @connections << connection
    connection.add_listener(editor)
    editor.add_listener(connection)
    Thread.new { editor.initialize_listener(connection) } if hello['initialize']
    Thread.new { add_missing_connections(hello['connections']) }
    connection.read
  end

  def add_missing_connections(cons)
    cons.each do |connection|
      unless has_connection_with_key? connection['key']
        connect(connection['hostname'], connection['port'], false)
      end
    end
  end

  def has_connection_with_key?(key)
    return true if editor.key == key
    active_connections.find_all { |c| c.key == key }.any?
  end
end
