require_relative '../includes'

class TestEditor < Editor
  def initialize
    @test = true
    super
  end
end
