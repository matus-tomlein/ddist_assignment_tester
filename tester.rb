require 'java'
require 'sinatra'
require 'json'

require_relative 'compiler'
require_relative 'simulator'

port = ARGV.any? ? ARGV.shift.to_i : 4567
handin_path = ARGV.any? ? ARGV.join(' ') : 'handin'

Compiler.run(handin_path) do |editor|
  simulator = Simulator.new(editor)

  set :port, port

  get '/write' do
    protect_me do
      simulator.write_in_text_area params['msg'], params['caret']
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
    end
  end

  def protect_me
    begin
      res = yield
    rescue => e
      return { 'error' => e.message }.to_json
    end

    res
  end
end
