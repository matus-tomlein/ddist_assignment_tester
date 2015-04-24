require_relative 'compiler'

Compiler.run do
  Simulator.run('handin-compiled')
end
