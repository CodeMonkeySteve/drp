
require 'rubygems'
require 'drp'

class OddsAndEnds

  extend DRP::RuleEngine

  def initialize num_codons
    @array_of_goodies = %w{ lollypop hotpants sunset whalesong }
    @num_codons = num_codons
    @codons = Array.new(num_codons) { rand }
    @c_index = 0
  end

  def next_codon
    @c_index = 0 if @c_index == @num_codons
    cod = @codons[@c_index]
    @c_index += 1
    cod 
  end

 begin_rules

  max_depth 2..4

  def max_depth_string
    "max_depth = #{max_depth}"
  end

  def depth_example
    "#{depth} #{depth_example}"
  end

  def depth_indirect_a
    "#{depth} #{depth_indirect_b}"
  end
  def depth_indirect_b
    "#{depth} #{depth_indirect_a}"
  end

  def map_range
    val = map 0..10
    "#{val} #{map_range}"
  end

  def map_range_i
    index = map 0..3, :i_lin
    @array_of_goodies[index] + ' ' +  map_range_i
  end

  def map_block
    val = map { |x,y| x * y * 10 }
    "#{val} #{map_block}"
  end

  def next_codons
    "you can even get the next_codon: #{next_codon},\nand next_meta_codon: #{next_meta_codon}"
  end

 end_rules

  def default_rule_method
    "!"
  end

end

oae = OddsAndEnds.new(40)

puts "querying for the max_depth:"
puts oae.max_depth_string
puts

puts "simple depth example:"
puts oae.depth_example
puts

puts "indirect depth example:"
puts oae.depth_indirect_a
puts

puts "map a range:"
puts oae.map_range
puts

puts "map an integer range:"
puts oae.map_range_i
puts

puts "map a block:"
puts oae.map_block
puts

puts oae.next_codons
puts
