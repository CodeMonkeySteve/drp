
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

require 'rubygems'
require 'drp'

class SymbolicRegressionExample

  extend DRP::RuleEngine

  GREATEST_FLOAT_SMALLER_THAN_1 = 1 - Float::EPSILON

  def initialize codons
    @codons = codons
    @num_codons = codons.size
    @index = 0
  end

  def next_codon
    res = @codons[@index]
    @index += 1
    @index = 0 if @index == @num_codons 
    clamp res
  end

  def clamp float
    return GREATEST_FLOAT_SMALLER_THAN_1 if float > GREATEST_FLOAT_SMALLER_THAN_1
    return 0.0 if float < 0.0
    float
  end

  def test value
    @index = 0
    @input = value
    expr
  end

  begin_rules

  max_depth 2..4

  def op x, y
    x + y
  end
  def op x, y
    x * y
  end
  def op x, y
    x - y
  end
  def op x, y
    if y == 0
      1
    else
      x / y
    end
  end

  def expr
    #puts "op(expr,expr)"
    op(expr, expr)
  end
  def expr
    #puts "@input"
    @input
  end
  def expr
    #puts "map"
    map -5..5, :i_lin
  end

  end_rules

end

#############################################

NUM_TEST_VALUES = 10
SWARM_SIZE      = 250
VECTOR_SIZE     = 16
NUM_ITER        = 1000
REBIRTH         = 0.0

pso_class = DRP::SearchAlgorithms::PSO::ParticleSwarmOptimizer
pso = pso_class.new SWARM_SIZE, VECTOR_SIZE, REBIRTH

expr = proc { |x| x**2 + 1 }
values = Array.new(NUM_TEST_VALUES) { rand * 2 - 1 }
solutions = values.collect &expr

NUM_ITER.times do |iter|
  pso.each do |codons|
    error = 0
    sr = SymbolicRegressionExample.new codons
    values.each_with_index do |val, i|
      error += (sr.test(val) - solutions[i]).abs
    end
    error
  end
  gbe = pso.global_best_error
  puts "iter #{iter+1}, best error: #{gbe}"
  break if gbe < 0.000001
end

winner = SymbolicRegressionExample.new(pso.global_best_vector)
puts "winning error: #{pso.global_best_error}"
NUM_TEST_VALUES.times do |i|
  puts "#{values[i]} -> #{winner.test(values[i])} [#{solutions[i]}]"
end
