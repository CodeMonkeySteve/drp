
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

class TestInstanceMethodsHelper
  
  extend DRP::RuleEngine

  MAX_DEPTH = 10
  MAX_DEPTH_2 = 3
  DEFAULT_NUM_CODONS = 40

  attr_reader :minimum_depth, :maximum_depth, :depths

  def initialize codons = nil
    @minimum_depth = 2000000000 
    @maximum_depth = 0
    @depths = []
    self.codons= codons
    # init_drp
  end

  def next_codon
    @codon_index = 0 if @codon_index == @num_codons
    res = @codons[@codon_index]
    @codon_index += 1
    res
  end

  def codons= codons
    @codons = codons || Array.new(DEFAULT_NUM_CODONS) { rand }
    @codon_index = 0
    @num_codons = @codons.size
  end

  begin_rules

  ### depth tests ###

  # because there is only ever one LHS
  # in the follwing rules, each one is always
  # picked and hence is deterministic and
  # recursed to the maximum depth.

  max_depth MAX_DEPTH

  def test_depth_pre
    register_depth
    test_depth_pre
  end

  def test_depth_post
    test_depth_post
    register_depth
  end

  def test_depth_2_rules
    @depths << depth
    other_rule
    test_depth_2_rules
  end

  max_depth MAX_DEPTH_2

  def other_rule
    @depths << depth
    other_rule
  end

  end_rules

  def register_depth
    the_depth = depth
    @depths << the_depth
    # print @depths, "\n"
    @minimum_depth = the_depth if the_depth < @minimum_depth
    @maximum_depth = the_depth if the_depth > @maximum_depth
  end

end

class TestInstanceMethods < Test::Unit::TestCase

  MD = TestInstanceMethodsHelper::MAX_DEPTH
  MD2 = TestInstanceMethodsHelper::MAX_DEPTH_2

  def setup
    @drp_obj = TestInstanceMethodsHelper.new
  end

  def test_depth_pre
    @drp_obj.test_depth_pre
    assert_equal 1, @drp_obj.minimum_depth
    assert_equal MD, @drp_obj.maximum_depth
    assert_equal (1..MD).to_a, @drp_obj.depths
    # assert false, "NOTE: just to have a false assertion for gemspec"
  end

  def test_depth_post
    @drp_obj.test_depth_post
    assert_equal 1, @drp_obj.minimum_depth
    assert_equal MD, @drp_obj.maximum_depth
    assert_equal (1..MD).to_a.reverse, @drp_obj.depths
  end

  def test_depth_2_rules
    @drp_obj.test_depth_2_rules
    depths_should_be = []
    MD.times do |i|
      depths_should_be << (i + 1)
      MD2.times do |j|
        depths_should_be << (j + 1)
      end
    end
    assert_equal depths_should_be, @drp_obj.depths
  end

  def test_map_range

    # NOTE the following effectively tests Utils::RangeFunctions as well

    assert_kind_of Float, @drp_obj.map(0..1)
    assert_kind_of Float, @drp_obj.map(0.0..1.0) 

    single_codon 0.0

    # linear function tests
    r = @drp_obj.map 0..1
    assert_equal r, 0.0

    r = @drp_obj.map 1..0
    assert_equal r, 1.0
    r = @drp_obj.map -12.3..12.3
    assert_equal r, -12.3
    r = @drp_obj.map 12.3..-12.3
    assert_equal r, 12.3

    single_codon 0.5

    # linear function tests
    r = @drp_obj.map 0..1
    assert_equal r, 0.5
    r = @drp_obj.map 1..0
    assert_equal r, 0.5
    r = @drp_obj.map -12.3..12.3
    assert_equal r, 0
    r = @drp_obj.map 12.3..-12.3    
    assert_equal r, 0

    single_codon 1.0

    # linear function tests
    r = @drp_obj.map 0..1
    assert_equal r, 1.0
    r = @drp_obj.map 1..0
    assert_equal r, 0.0
    r = @drp_obj.map -12.3..12.3
    assert_equal r, 12.3
    r = @drp_obj.map 12.3..-12.3
    assert_equal r, -12.3

  end

  def test_map_block

    num_codons = 10
    codons = Array.new(num_codons) { rand }
    set_codons codons
    
    # assert_nil(codons.detect { |c| c >= 1.0 || c < 0.0 })
    identity = proc { |x| x }
    no_params = proc {}
    local = codons.collect &identity
    mapped = []

    num_codons.times do
      mapped << @drp_obj.map(&identity)
    end

    assert_equal local, mapped

    # test multiple params
    set_codons [1,2,3]
    r = @drp_obj.map { |a,b,c,d| [a,b,c,d] }
    assert_equal [1,2,3,1], r

    assert_raise(ArgumentError) { @drp_obj.map &no_params }

    # should not accept args and block
    assert_raise(ArgumentError) { @drp_obj.map 0..1, &identity }
    assert_raise(ArgumentError) { @drp_obj.map 0..1, :linear,  &identity }

  end

  def single_codon codon
    @drp_obj.codons = [codon]
  end
  def set_codons codons
    @drp_obj.codons = codons
  end

end
