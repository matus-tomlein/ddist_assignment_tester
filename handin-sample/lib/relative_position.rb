class RelativePosition
  attr_accessor :content, :next, :previous, :replaced_by
  attr_reader :key

  def self.generate_key
    @key = (0...8).map { (65 + rand(26)).chr }.join
  end

  def initialize(key)
    @key = key
  end

  def find(i)
    return self if i == 0 || self.next.nil?
    self.next.find(i - 1)
  end

  def absolute_position
    return 0 if previous.nil?

    1 + previous.absolute_position
  end
end
