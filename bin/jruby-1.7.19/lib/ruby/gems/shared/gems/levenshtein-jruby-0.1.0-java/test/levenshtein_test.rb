require 'test_helper'

class LevenshteinTest < Test::Unit::TestCase
  
  def test_levenshtein
    assert Levenshtein.distance("test", "Test") == 1
  end

  def test_levenshtein_threshold
    assert Levenshtein.distance("test 1", "Test 2", 1) == -1
    assert Levenshtein.distance("test 1", "Test 2", 3) == 2
  end
end