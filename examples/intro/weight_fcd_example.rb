require 'rubygems'
require 'drp'

class WeightFromCurrentDepthExample

  extend DRP::RuleEngine

 begin_rules

  max_depth 25
  weight_fcd 20..0.1

  def foo
    "foo #{foo}"
  end

  weight 1

  def foo
    "bar!"
  end

  def mama
    "mama #{mama}"
  end
  def mama
    "mia!"
  end

 end_rules

end

3.times do
  wfcde = WeightFromCurrentDepthExample.new
  3.times do
    puts wfcde.foo
  end
  puts
  3.times do
    puts wfcde.mama
  end
  puts
end
