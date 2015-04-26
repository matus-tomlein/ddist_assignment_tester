require 'open-uri'
require 'json'
require 'cgi'

require_relative 'helpers'

class Commander
  attr_reader :connections, :server

  include TestHelper
  include ConnectionHelper

  def initialize
    initialize_connections
  end

  def add(args)
    @connections[args.shift] = [ args.shift, args.shift.to_i ]
  end

  def list(args)
    puts @connections
  end

  def connect(args)
    host, port = connection_host_and_port(args.last)
    get args.first, '/connect', { host: host, port: port.to_i + 10 }
  end
  alias_method :c, :connect

  def disconnect(args)
    get args.first, '/disconnect'
  end
  alias_method :dc, :disconnect

  def listen(args)
    host, port = connection_host_and_port(args.first)
    get args.first, '/listen', { port: port.to_i + 10 }
  end
  alias_method :l, :listen

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
end
