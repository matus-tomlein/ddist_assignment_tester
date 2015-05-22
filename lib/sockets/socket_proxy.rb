require 'thread'

require_relative 'delayed_jobs'
require_relative 'shuffled_jobs'
require_relative 'sender'

class SocketProxy
  def self.start_proxy
    require_relative 'socket_listener'
    begin
      java_import 'tester.ProxiedServerSocket'
      java_import 'tester.ProxiedSocket'
      listener = SocketListener.new
      ProxiedServerSocket::listener = listener
      ProxiedSocket::listener = listener
    rescue => e
      puts e.message
    end
  end

  def self.shuffle(window)
    proxies.each { |proxy| proxy.shuffle(window) }
  end

  def self.throttle(direction, speed)
    proxies.each { |proxy| proxy.throttle(direction, speed) }
  end

  def self.proxies; @socket_proxies ||= []; end

  def self.create_and_start(host, port, actual_port, proxy_type = :server)
    proxies.each do |proxy|
      if proxy.host == host and proxy.port == port
        proxy.activate
        return
      end
    end
    SocketProxy.new(host, port, actual_port, proxy_type).start
  end

  attr_accessor :active, :host, :port
  attr_reader :sender

  def initialize(host, port, actual_port, proxy_type = :server)
    @host = host
    @port = port
    @actual_port = actual_port
    @proxy_type = proxy_type
    @sockets = []
    @sender = Sender.new
    @delayed_jobs = DelayedJobs.new(@sender)
    @shuffled_jobs = ShuffledJobs.new(@sender)
    @throttling = {}

    puts "Proxy initialized with #{port} and #{actual_port}"

    SocketProxy.proxies << self
  end

  def activate
    @sender.active = true
  end

  def start
    sender.active = true
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
    begin
      loop do
        break unless sender.active

        msg = source.recv 10000
        if msg.empty?
          destination.close
          puts "Received an empty message, stopping communication"
          stop if direction == :download
          break
        else
          send(direction, destination, msg)
        end
      end
    rescue => ex
      puts ex.message
    end
  end

  def stop
    @sockets.each do |socket|
      socket.close unless socket.closed?
    end
    @sockets = []
    sender.active = false
  end

  def send(direction, socket, msg)
    job = {
      socket: socket,
      msg: msg
    }

    if should_shuffle(direction)
      @shuffled_jobs.shuffle job
    elsif @throttling[direction] and @throttling[direction] > 0
      @delayed_jobs.delay job, @throttling[direction]
    else
      @sender.send job
    end
  end

  def throttle(direction, speed)
    @throttling[direction] = speed.to_i
  end

  def should_shuffle(direction)
    return false if @shuffled_jobs.window == 0
    direction == :download and @proxy_type == :server
  end

  def shuffle(window)
    @shuffled_jobs.set_window window.to_f
  end
end
