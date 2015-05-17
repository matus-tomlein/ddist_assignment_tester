require 'open-uri'
require 'json'
require 'cgi'

require_relative 'helpers'
require_relative 'time_keeper'
require_relative 'data_collection'
require_relative 'string_distance'

class Commander
  attr_reader :connections, :server

  SLOW_TYPING = 0.2
  SLOWER_TYPING = 0.1
  LESS_SLOWER_TYPING = 0.08
  FAST_TYPING = 0.05
  REALLY_FAST_TYPING = 0.01

  THROTTLING_A_BIT = 3
  THROTTLING_SLOW = 6
  THROTTLING_VERY_SLOW = 9

  REORDERING_SMALL_WINDOW = 0.1
  REORDERING_BIGGER_WINDOW = 0.5
  REORDERING_LARGE_WINDOW = 1

  include TestHelper
  include ConnectionHelper

  def self.running_test(name = nil)
    @running_test = name if name
    @running_test ||= ''
  end

  def initialize
    initialize_connections
  end

  def tests(args)
    puts (File.read 'docs/tests.txt').blue
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

  def write_with_speed(args)
    caret = args.shift.to_i
    client = args.shift
    speed = args.shift.to_f
    get client, '/write', {
      caret: caret,
      speed: speed,
      msg: args.join(' ')
    }
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

  def shuffle(args)
    get args.shift, '/shuffle', {
      'window' => args.shift
    }
  end

  def throttle(args)
    get args.shift, '/throttle', {
      'direction' => args.shift,
      'speed' => args.shift
    }
  end

  def debug(args)
    @debug = true
  end

  def matus(args)
    unless args.any?
      puts 'What?'
    else
      msg = args.join ' '
      DataCollection.feedback msg
      puts 'Totally!'
    end
  end

  def start_watching_content(args)
    get args.first, '/start_watching_content'
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
