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
    Thread.new do
      @server = TCPServer.open(port)
      loop do
        Thread.start(@server.accept) do |socket|
          # exchange keys
          socket.puts(editor.key)
          key = socket.gets.chop

          start_connection key, socket
        end
      end
    end
  end

  def connect(host, port)
    Thread.start(TCPSocket.open(host, port)) do |socket|
      # exchange keys
      key = socket.gets.chop
      socket.puts(editor.key)

      start_connection key, socket
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

  private

  def start_connection(key, socket)
    connection = Connection.new(key, socket)
    @connections << connection
    connection.add_listener(editor)
    editor.add_listener(connection)
    Thread.new { editor.initialize_listener(connection) }
    connection.read
  end
end
