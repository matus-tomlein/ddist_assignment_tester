require 'open-uri'
require 'json'
require 'cgi'

require_relative 'helpers'
require_relative 'time_keeper'
require_relative 'data_collection'

class Commander
  attr_reader :connections, :server

  include TestHelper
  include ConnectionHelper

  def self.running_test(name = '')
    @running_test ||= name
  end

  def initialize
    initialize_connections
  end

  def add(args)
    host = args.shift
    port = args.shift.to_i
    app_port = port + 10
    @connections[args.shift] = [ host, port, app_port ]
  end

  def list(args)
    puts @connections
  end

  def connect(args)
    host, port, app_port = connection_host_and_port(args.last)
    get args.first, '/connect', { host: host, port: app_port }
  end
  alias_method :c, :connect

  def disconnect(args)
    get args.first, '/disconnect'
  end
  alias_method :dc, :disconnect

  def listen(args)
    host, port, app_port = connection_host_and_port(args.first)
    get args.first, '/listen', { port: app_port }
  end
  alias_method :l, :listen

  def shutdown(args)
    get args.first, '/exit'
  end

  def set_caret(args)
    get args.shift, '/set_caret', { caret: args.shift.to_i }
  end

  def clear(args)
    get args.shift, '/clear'
  end

  def read_area1(args)
    get args.shift, '/read_area1'
  end

  def read(args)
    get args.shift, '/read'
  end

  def write(args)
    caret = args.shift.to_i

    get args.shift, '/write', {
      caret: caret,
      msg: args.join(' ')
    }
  end

  def synchronize_time(args)
    TimeKeeper.start_new_checkpoint
    args.each do |client|
      Thread.new { get client, '/synchronize_time' }
    end
  end

  def event_history(args)
    get args.shift, '/event_history'
  end

  def debug(args)
    @debug = true
  end

  private

  def listen_and_update_port(server)
    port = listen [server]
    if port
      host, old_port, app_port = connection_host_and_port(server)
      @connections[server] = [ host, old_port, port.to_i ]
    end
    port
  end
end
