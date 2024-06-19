require 'rubygems'
require 'drp'

class ToyExample

  extend DRP::RuleEngine

 begin_rules

  def foobar
    "foo #{foobar}"
  end
  def foobar
    "bar!"
  end

 end_rules

end

toy = ToyExample.new
puts Array.new(3) { toy.foobar } # -> [ 'foo foo foo bar!', 'bar!', 'foo bar!' ]
