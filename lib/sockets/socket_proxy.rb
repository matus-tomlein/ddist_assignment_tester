class SocketProxy
  def initialize(host, port, actual_port, proxy_type = :server)
    puts "Initializing SocketProxy #{host} #{port} #{actual_port} #{proxy_type}"
    @host = host
    @port = port
    @actual_port = actual_port
    @proxy_type = proxy_type
  end

  def start
    Thread.new(TCPServer.new(@port)) do |server|
      server_loop server
    end
  end

  def server_loop(server)
    loop do
      Thread.new(server.accept) do |client|
        client_accepted(client)
      end
    end
  end

  def client_accepted(client)
    TCPSocket.open(@host, @actual_port) do |server|
      puts "Opened connection to server #{server}"
      Thread.new { proxy_sockets(client, server) }
      proxy_sockets(server, client)
    end
  end

  def proxy_sockets(client, server)
    loop do
      msg = client.recv 10000
      server.send msg, 0
    end
  end
end
