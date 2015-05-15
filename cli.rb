require_relative 'lib/gems'

require 'colored'
puts (File.read 'docs/cli_intro.txt').blue

require_relative 'lib/update_checker'
require_relative 'lib/commander'
Dir["tests/*.rb"].each {|file| require file }

class Cli
  attr_reader :commander

  def initialize(commander)
    @commander = commander
  end

  def run
    loop do
      cmd = gets.chomp
      break if cmd == 'exit'
      next if cmd == ''

      args = cmd.split
      cmd_name = args.shift

      if commander.class.method_defined? cmd_name
        Commander.running_test(cmd_name)
        commander.send cmd_name.to_sym, args
      else
        puts 'Unknown command'
      end
    end
  end
end

DataCollection.init
UpdateChecker.check

# Start the CLI interface
Cli.new(Commander.new).run
