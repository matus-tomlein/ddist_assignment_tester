require 'levenshtein-jruby'

class StringDistance
  attr_reader :distance

  def self.calculate_distance(string1, string2)
    Levenshtein.distance(string1, string2)
  end
end
