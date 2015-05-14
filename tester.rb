require 'java'
require 'sinatra'
require 'json'
require 'ostruct'

require_relative 'lib/java_classes'
require_relative 'lib/compiler'
require_relative 'lib/simulator'
require_relative 'lib/time_keeper'
require_relative 'lib/event_history'
require_relative 'lib/content_watcher'

$instances = OpenStruct.new

port = ARGV.any? ? ARGV.shift.to_i : 4567
handin_path = ARGV.any? ? ARGV.join(' ') : 'handin'

Thread.new do
  begin
    Compiler.run(handin_path) do |editor_access|
      $instances.simulator = Simulator.new(editor_access)
      $instances.content_watcher = ContentWatcher.new(editor_access.upper_text_area)
    end
  rescue => ex
    puts ex.message
  end
end

set :environment, :production
set :port, port

get '/write' do
  protect_me do
    if params['speed']
      simulator.write_in_text_area params['msg'], params['caret'], params['speed'].to_f
    else
      simulator.write_in_text_area params['msg'], params['caret']
    end
  end
end

get '/set_caret' do
  protect_me do
    simulator.set_caret_position params['caret']
  end
end

get '/read_area1' do
  protect_me do
    simulator.read_text_area
  end
end

get '/read' do
  protect_me do
    simulator.read_bottom_text_area
  end
end

get '/listen' do
  protect_me do
    simulator.listen params['port'].to_i
    sleep 1
    simulator.current_port.to_s
  end
end

get '/connect' do
  protect_me do
    simulator.connect params['host'], params['port'].to_i
  end
end

get '/disconnect' do
  protect_me do
    simulator.disconnect
  end
end

get '/clear' do
  protect_me do
    simulator.clear_text_area
    'OK'
  end
end

get '/synchronize_time' do
  TimeKeeper.start_new_checkpoint
end

get '/exit' do
  Thread.new { sleep 1; Process.kill 'INT', Process.pid }
  'OK'
end

get '/start_watching_content' do
  content_watcher.start_watching
end

get '/event_history' do
  EventHistory.drop.to_json
end

def protect_me
  begin
    res = yield
  rescue => e
    puts e.message
    puts e.backtrace.join("\n")
    return { 'error' => e.message }.to_json
  end
  res
end

def simulator
  raise "Not initialized yet" unless $instances.simulator
  $instances.simulator
end

def content_watcher
  raise "Not initialized yet" unless $instances.content_watcher
  $instances.content_watcher
end
