require_relative 'lib/commander'
require_relative 'tests/commander_test1'
require_relative 'tests/commander_test2'
require_relative 'tests/commander_test3'
require_relative 'tests/commander_test4'

class Cli
  attr_reader :commander

  def initialize(commander)
    @commander = commander
  end

  def run
    loop do
      cmd = gets.chomp
      break if cmd == 'exit'

      args = cmd.split
      cmd_name = args.shift

      if commander.class.method_defined? cmd_name
        commander.send cmd_name.to_sym, args
      else
        puts 'Unknown command'
      end
    end
  end
end

# Start the CLI interface
Cli.new(Commander.new).run
