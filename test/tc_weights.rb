
=begin 

DRP, Genetic Programming + Grammatical Evolution = Directed Ruby Programming
Copyright (C) 2006, Christophe McKeon

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Softwar Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=end

############### STATIC WEIGHTS ###############

=begin
  weight 10.0                         static weight
  weight 0..1                         static mapped
  weight 0..1, :function              static mapped w/ function
  weight {}                           static proc gets codons
=end

class TestStaticWeightsHelper

  extend DRP::RuleEngine
  
  attr_writer :codon
  attr_reader :_1, :_0, :_33, :_67, :_m1, :_m01_02, :_p30, :_p70

  def initialize codon = nil
    @codon = codon
    @_1 = @_0 = @_33 = @_67 = @_m1 = @_m01_02 =  @_p30 = @_p70 = 0
  end

  def next_codon
    @codon || rand
  end

 begin_rules

  # test constant

  weight 1
  def _1_0
    @_1 += 1
  end

  weight 0
  def _1_0
    @_0 += 1
  end

  weight 33
  def _33_67
    @_33 += 1
  end

  weight 67
  def _33_67
    @_67 += 1
  end

  # test mapped

  weight 0.1..0.2
  def mapped
    @_m01_02 += 1
  end

  weight 1
  def mapped
    @_m1 += 1
  end

  # test proc

  weight { |x,y,z| ((x + y + z) * 100).to_i }
  def proc
    @_p30 += 1
  end

  weight 70
  def proc
    @_p70 += 1
  end

 end_rules

end

class TestStaticWeights < Test::Unit::TestCase

  def test_constant
    ts = TestStaticWeightsHelper.new
    100.times do |i|
      ts.codon = i.to_f/100
      ts._1_0 
      ts._33_67
    end
    assert_equal 100, ts._1
    assert_equal 0,   ts._0
    assert_equal 33,  ts._33
    assert_equal 67,  ts._67
  end

  def test_mapped
    ts = TestStaticWeightsHelper.new
    100.times do |i|
      ts.codon = i.to_f/100
      ts.mapped
    end
    m = ts._m01_02
    m1 = ts._m1
    # puts ">>>>>", m, m1, "<<<<<"
    # these figures take normalization into account
    assert m >= 9 && m <= 17
    assert m1 >= 83
  end

  def test_mapped_w_function
    # TODO no functions yet
    assert true
  end

  def test_proc
    ts = TestStaticWeightsHelper.new(0.1)
    # since the codon is set here
    # to 0.1 then (x + y + z) * 100 in proc equal 30
    100.times do |i|
      ts.codon = i.to_f/100
      ts.proc
    end
    assert_equal 30, ts._p30
    assert_equal 70, ts._p70
  end

end

############### FROM CURRENT DEPTH WEIGHTS ##################


=begin
  weight_fcd 0..1                     dynamic from current depth (uses max_depth)
  weight_fcd 0..1, :function          dynamic fcd w/ function
  weight_fcd 0..1, 0..1               dynamic like previous but start
                                        and end of range mapped from codons
  weight_fcd 0..1, 0..1, :function    like previous with function
                                        the function applies to the dynamic mapping
                                        of the current depth, and not the static
                                        mapping via codons of start and end
                                        which is always just linear
  weight_fcd { |max_depth|            dynamic, expects a block which takes the 
               ...                      max_depth and returns a proc which 
               proc {|depth| ... }      which takes the current depth
             }                      
=end

class TestFCDWeightsHelper

  extend DRP::RuleEngine

  attr_reader :str

  def initialize
    reset
  end
  def reset
    @str = ''
  end

  begin_rules

  max_depth 3

  weight_fcd 1.0..0.0
  def simple
    @str << 'a'
    # print @str, '>>', depth, "\n"
    simple
  end

  weight_fcd 0.0..1.0
  def simple
    @str << 'b'
    # print @str, '>>', depth, "\n"
    simple
  end

  end_rules

end

class TestFCDWeights < Test::Unit::TestCase

  def test_simple
    td = TestFCDWeightsHelper.new
    100.times do
      td.simple
      # on first pick 'a' must be chosen w/ 1.0 vs 0.0 weight
      # on second pick 'a' must be chosen with 0.5 vs 0 weight
      # on third pick 'a' and 'b' both have weight 0 so
      #   either can be chosen
      # if 'a' was chosen on third then
      #   all the rest will be 'b' because 'a' has exceeded  max depth 3
      # else
      #   on fourth pick 'b' must be chosen because it now has weight
      #     0.5 vs 'a' which still has weight 0.0
      #   on fifth pick 'b' must be chosen because it now has weight 1.0
      #   on sixth pick 'a' is the only active rule method because 'b' has
      #     gone past it's max_depth, so 'a' must be picked
      assert ('aaabbb' ==  td.str) || ('aabbba' ==  td.str)
      td.reset
    end
  end

end

##############################################################








############### DYNAMIC WEIGHTS ##############

=begin
  weight_dyn 0..1                     codon maps to range for every rule method choice
  weight_dyn 0..1, :function          same but using function
  weight_dyn 0..1, 0..1               initial min and max determined by metacodons
                                        and further runtime mapping also
  weight_dyn 0..1, 0..1, :function    same but function used for runtime mapping
  weight_dyn { |codon| }              same but using user block, gets meta_codons
=end

=begin NOT SURE HOW USEFUL 'DYNAMIC' WEIGHTS ARE

class TestDynamicWeightsHelper

  extend DRP::RuleEngine

  attr_reader :test_simple_count, :num_meta_codon_requests, :num_codon_requests

  def initialize codon = nil
    @codon = codon
    reset
  end

  def next_codon
    @num_codon_requests += 1
    @codon || rand
  end

  def next_meta_codon
    @num_meta_codon_requests += 1
    rand
  end

  def reset
    @num_codon_requests = 0
    @num_meta_codon_requests = 0
  end

 begin_rules

  weight_dyn 0..1
  def test_simple
  end
  def test_simple
  end

  weight_dyn 0..1, 0..1
  def test_init_range
  end
  def test_init_range
  end

 end_rules

end

class TestDynamicWeights < Test::Unit::TestCase

  # this is a very indirect test
  def test_simple
    td = TestDynamicWeightsHelper.new
    # 4 meta_codons are used to initialize test_init_range weights
    # so need to reset
    td.reset
    n = 10
    n.times do
      td.test_simple
    end
    # both test_simple rule methods get weights
    # allocated via meta_codons for each and every choice
    assert_equal n * 2, td.num_meta_codon_requests
    # once the weights are set a rule must be
    # picked which uses a regular codon
    assert_equal n, td.num_codon_requests
  end

  def test_init_range
    td = TestDynamicWeightsHelper.new
    # 4 meta_codons are used to initialize test_init_range weights
    assert_equal 4, td.num_meta_codon_requests
    n = 10
    n.times do
      td.test_init_range
    end
    # both test_init_range rule methods get
    # their initial weight range set at initialization time
    # which requires 2 metacodons each.
    assert_equal (n * 2) + 4, td.num_meta_codon_requests
    # once the weights are set a rule must be
    # picked which uses a regular codon
    assert_equal n, td.num_codon_requests
  end

end

=end


=begin

ITER_TEST_DEFAULT_NUM_ITER = 1000
ITER_TEST_MAX_NUM_ITER = 100000

def iter_test(
  test_helper, selector, expected = true, 
  num_iter = ITER_TEST_DEFAULT_NUM_ITER,
  max_num_iter = ITER_TEST_MAX_NUM_ITER
)
 
  if num_iter > max_num_iter
    return false
  end

  test = true
  num_iter.times do
    test &&= test_helper.send(selector)
  end

  if test == expected
    return true
  else
    return iter_test(test_helper, selector, expected, num_iter * 2, max_num_iter)
  end

end

# non deterministic assert
def nd_assert test_helper, selector, expected = true 
  val = iter_test(test_helper, selector, expected)
  msg = "nondeterministic test failure: '#{selector}', " +
        # TODO these instructions should be in the docs
        "run 'rake test' a few more times to double check"
  assert val, msg
end

=end

