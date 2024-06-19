require 'rubygems'
require 'drp'

class WeightsExample2

  extend DRP::RuleEngine

 begin_rules

  max_depth 2
  weight 0..1

  def foo
    "foo1 #{foo}"
  end
  def foo
    "foo2 #{foo}"
  end

 end_rules

end

3.times do
  we2 = WeightsExample2.new
  3.times do
    puts we2.foo
  end
  puts
end
