require 'thread'

class SocketProxy
  def self.start_proxy
    require_relative 'socket_listener'
    java_import 'tester.ProxiedServerSocket'
    java_import 'tester.ProxiedSocket'
    listener = SocketListener.new
    ProxiedServerSocket::listener = listener
    ProxiedSocket::listener = listener
  end

  def self.throttle(direction, speed)
    proxies.each { |proxy| proxy.throttle(direction, speed) }
  end

  def self.proxies; @socket_proxies ||= []; end

  def self.create_and_start(host, port, actual_port, proxy_type = :server)
    proxies.each do |proxy|
      if proxy.host == host and proxy.port == port
        proxy.active = true
        return
      end
    end
    SocketProxy.new(host, port, actual_port, proxy_type).start
  end

  DELAY = 0.1

  attr_accessor :active, :host, :port

  def initialize(host, port, actual_port, proxy_type = :server)
    @host = host
    @port = port
    @actual_port = actual_port
    @proxy_type = proxy_type
    @sockets = []
    @throttling = {}
    @tick_lock = Mutex.new
    @delayed_jobs = []
    @ready_jobs = Queue.new

    puts "Proxy initialized with #{port} and #{actual_port}"

    SocketProxy.proxies << self
    process_delayed_jobs
    process_ready_jobs
  end

  def start
    @active = true
    puts "Proxy listening on port #{@port}"
    Thread.new(TCPServer.new(@port)) do |server|
      @tcp_server = server
      server_loop
    end
  end

  def server_loop
    loop do
      Thread.new(@tcp_server.accept) do |client|
        @sockets << client
        client_accepted(client)
      end
    end
  end

  def client_accepted(client)
    puts "Proxy received client, connecting to #{@host} and #{@actual_port}"
    TCPSocket.open(@host, @actual_port) do |server|
      puts "Proxy connected"
      @sockets << server
      Thread.new { proxy_sockets(client, server, :upload) }
      proxy_sockets(server, client, :download)
    end
  end

  def proxy_sockets(source, destination, direction)
    loop do
      break unless active

      msg = source.recv 10000
      if msg.empty?
        destination.close
        puts "Received an empty message, stopping communication"
        stop if direction == :download
        break
      else
        delay(direction, destination, msg)
      end
    end
  end

  def stop
    @sockets.each do |socket|
      socket.close
    end
    @sockets = []
    @active = false
  end

  def delay(direction, socket, msg)
    job = {
      socket: socket,
      msg: msg
    }

    begin
      time = @throttling[direction]
      if time and time > 0
        @tick_lock.synchronize do
          (@delayed_jobs[time] ||= []) << job
        end
      else
        @ready_jobs << job
      end
    rescue => ex
      puts ex.message
    end
  end

  def throttle(direction, speed)
    @throttling[direction] = speed.to_i
  end

  def process_delayed_jobs
    Thread.new do
      loop do
        begin
          jobs = @tick_lock.synchronize { @delayed_jobs.shift }

          jobs.each { |job| @ready_jobs << job } if active and jobs
        rescue => ex
          puts ex.message
        end

        sleep DELAY
      end
    end
  end

  def process_ready_jobs
    Thread.new do
      loop do
        job = @ready_jobs.pop
        job[:socket].send(job[:msg], 0) if active
      end
    end
  end
end
