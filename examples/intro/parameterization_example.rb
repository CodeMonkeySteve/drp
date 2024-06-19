
require 'rubygems'
require 'drp'

class ParameterizationExample

  extend DRP::RuleEngine

 begin_rules

  max_depth 3

  def foo n
    "[" + foo(n + 1) + "]"
  end
  def foo n
    "<#{n}>" + foo(n)
  end

 end_rules

  def default_rule_method n
    "<<#{n * 2}>>!!"
  end

end

pe = ParameterizationExample.new
3.times do 
  puts pe.foo(0)
end 

