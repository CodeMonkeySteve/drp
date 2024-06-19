require 'rubygems'
require 'drp'

class WeightsExample

  extend DRP::RuleEngine

 begin_rules

  max_depth 3
  weight 1

  def foo
    "foo1 #{foo}"
  end

  weight 8

  def foo
    "foo2 #{foo}"
  end

 end_rules

end

3.times do
  we = WeightsExample.new
  3.times do
    puts we.foo
  end
  puts
end
