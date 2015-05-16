# http://commons.apache.org/proper/commons-lang/apidocs/org/apache/commons/lang3/StringUtils.html

require 'commons-lang3-3.1'

module Levenshtein
  java_import org.apache.commons.lang3.StringUtils

  # Find the Levenshtein distance between two strings.
  def self.distance(string1, string2, threshold=nil)
    if threshold
      StringUtils.get_levenshtein_distance(string1, string2, threshold)
    else
      StringUtils.get_levenshtein_distance(string1, string2)
    end
  end
end