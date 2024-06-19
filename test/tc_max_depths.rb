
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

class TestMaxDepthsHelper

  extend DRP::RuleEngine

  attr_reader :test_simple_depth_attained

  def initialize single_codon = nil
    @test_simple_depth_attained = 0
    @single_codon = single_codon
    # init_drp
  end

  # note max_depths call next_meta_codon
  # but their is a default next_meta_codon which
  # just calls next_codon
  def next_codon
    @single_codon || rand
  end

  begin_rules
  
  # note, some of these tests depend on  the return 
  # value of default_rule_method below

  max_depth 4
  def test_simple
    test_simple + 1
  end

  max_depth 3..9
  def test_map_range
    test_map_range + 1
  end

  max_depth { |x,y| x + y }
  def test_proc
    test_proc + 1
  end
 
  end_rules

  def default_rule_method
    0
  end

end

class TestMaxDepths < Test::Unit::TestCase

  def test_exceptions
    # TODO  
  end

  def test_simple
    @drp_obj = TestMaxDepthsHelper.new
    assert_equal 4, @drp_obj.test_simple
  end

  def test_map_range
    7.times do |i|
      codon = i/7.0
      @drp_obj = TestMaxDepthsHelper.new codon
      #puts "i: #{i}, cod: #{codon}, map: #{@drp_obj.test_map_range}"
      assert_equal i + 3, @drp_obj.test_map_range
    end
    @drp_obj = TestMaxDepthsHelper.new 0.99999999999
    assert_equal 9, @drp_obj.test_map_range
  end

  def test_proc
    @drp_obj = TestMaxDepthsHelper.new 3
    assert_equal 6, @drp_obj.test_proc
  end

end


