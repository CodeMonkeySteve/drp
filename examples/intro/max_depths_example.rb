require 'rubygems'
require 'drp'

class MaxDepthsExample

  extend DRP::RuleEngine

 begin_rules

  max_depth 2

  def foo
    "foo1 #{foo}"
  end

  max_depth 3

  def foo
    "foo2 #{foo}"
  end

 end_rules

  def default_rule_method
    "bar!"
  end

end

mde = MaxDepthsExample.new
3.times do
  puts mde.foo
end

