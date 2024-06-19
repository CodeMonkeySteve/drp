require 'rubygems'
require 'drp'

class MaxDepthsExample2

  extend DRP::RuleEngine

 begin_rules

  max_depth 0..3

  def foo
    "foo1 #{foo}"
  end

  def foo
    "foo2 #{foo}"
  end

 end_rules

end

3.times do
  mde2 = MaxDepthsExample2.new
  3.times do
    puts mde2.foo
  end
  puts
end
