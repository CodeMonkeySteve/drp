
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

module DRP

class RuleMethod

  attr_reader :depth, :max_depth

  def initialize drp_instance, method_name, weight_factory, max_depth
    @method = drp_instance.method method_name
    @max_depth = max_depth.value drp_instance
    @weight = weight_factory.call self, drp_instance
    @depth = 0
  end

  def expressed? 
    @depth < @max_depth
  end

  def call *args
    @depth += 1
    result = @method.call *args
    @depth -= 1
    result
  end

  def weight
    @weight.value
  end

end

module RuleEngine

  def new *a, &b 
    super.__drp__init
  end

 private

  def self.extend_object klass
    DRPNameClashError.test(klass) if DEFAULT[:test_for_extend_name_clashes]
    klass.class_eval do
      include InstanceMethods
    end
    super
  end

  def method_added name
    # explicit boolean test because can also be :finished
    if @__drp__defining_rules == true

      rule = @__drp__rules[name] ||= []

      # to stop recursion of method_added due to alias which calls it
      @__drp__defining_rules = false 
      class_eval "private :#{name}; alias __drp__#{name}__#{rule.size} #{name}"
      @__drp__defining_rules = true
      
      # note this comes after class_eval cuz of ref to rule.size there
      rule << [@__drp__weights.last, @__drp__max__depths.last]

    end
  end

 # TODO find way of making rdoc document these even if they are private
 public

  def begin_rules
    # if it is true or :finished, see end_rules & method_added
    if @__drp__defining_rules 
      raise DRPError, 'begin rules may only be called once'
    else
      @__drp__rules = {}
      @__drp__defining_rules = true
      @__drp__weights = []
      @__drp__max__depths = []
      # NB max_depth should come first here in case user changes
      # the default to some weight which needs to know the max_depth
      max_depth DEFAULT[:max_depth]
      weight DEFAULT[:weight]
    end
  end

  # NB the two methods defined via define_method in end_rules
  # will be instance methods in instances of classes which 
  # are extended by this module. they are here because they
  # are closures referencing the 'name' and 'all_methods' 
  # variables respectively. 
  # other non-closure methods are in module InstanceMethods

  def end_rules

    @__drp__defining_rules = :finished

    all_methods = {}

    @__drp__rules.each do |name, weights_and_max_depths|

      methods = []

      weights_and_max_depths.each_with_index do |w_md, i|
        methods.push ["__drp__#{name}__#{i}"] + w_md
      end

      all_methods[name] = methods

      define_method name do |*args|

        useable_methods = @__drp__rule__methods[name].select do |meth|
          meth.expressed?
        end

        case useable_methods.size

          when 0
          default_rule_method *args          

          when 1
          __drp__call__method(useable_methods.first, args)

          else
          __drp__call__method(__drp__choose__method(useable_methods), args)

        end
        
      end # define_method name do


    end # @__drp__rules.each do

    define_method :__drp__init do

      @__drp__rule__methods = {}
      @__drp__depth__stack = []
      @__drp__rule__method__stack = []

      all_methods.each do |name, arg_array|
        @__drp__rule__methods[name] = arg_array.collect do |args|
          RuleMethod.new self, *args
        end
      end

      self

    end

  end # end_rules

=begin rdoc

sets the maximum obtainable depth of the rule methods which follow it
in the listing. max_depths are set for each instance of the class you
extended with DRP::RuleEngine upon initialization (or when you call init_drp),
once and only once, and remains set to that static value. max depths are always
integer values.

it may be used in any of the following four ways:

*scalar*, all following rule_methods are set to given value

 max_depth 1                
                   
*range*, each following rule_method is initialized to some integer
from range.start to range.end inclusive using a linear mapping
of a codon gotten via the method next_meta_codon.

 max_depth 1..2             

same as the previous but uses the function given, at present
the only function implemented is i_linear (integer linear),
which is the default action when no function is given, so at 
present this is useless.

 max_depth 1..2, :function

*block*, each following rule_method is initialized to some integer
given by your block. the formal parameters to your supplied
block are counted, and the appropriate number of codons harvested using
InstanceMethods#next_meta_codon are passed to the block.

 max_depth { |next_meta_codon, ...| ... }
 
see example_2.rb

=end

  def max_depth *args, &block
    
    sz = args.size
    are_args = sz > 0
    md = nil
    
    if block_given?
      if are_args
        raise ArgumentError, 'max_depth called with both arguments and a block', caller
      else
        md = MaxDepths::ProcMaxDepth.new(block)
      end
    else
      case sz
      when 1
        arg = args[0]
        case arg
        when Numeric
          md = MaxDepths::StaticMaxDepth.new arg.to_i
        when Range
          md = MaxDepths::MappedMaxDepth.new arg
        else
          raise ArgumentError, 'bad argument to max_depth', caller
        end
      when 2
        arg1, arg2 = args
        if (arg1.kind_of? Range) && (arg2.kind_of? Symbol)
          md = MaxDepths::MappedMaxDepth.new arg1, arg2
        else
          raise ArgumentError, 'bad argument to max_depth', caller
        end
      else 
        raise ArgumentError, "too many (#{sz}) args passed to max_depth", caller
      end # case sz
    end # if block_given

    @__drp__max__depths << md

  end # def max_depth

=begin rdoc

sets the weight of the rule methods which follow it
in the listing, and may be used in any of the following four ways:

*scalar*, all following rule_methods are set to given value

max_depth 1                
                   
*range*, each following rule_method is initialized to some integer
from range.start to range.end inclusive using a linear mapping
of a codon gotten via the method next_meta_codon when your
extended object is initialized via drp_init.

max_depth 1..2             

same as the previous but uses the function given, at present
the only function implemented is i_linear (integer linear),
which is the default action when no function is given, so at 
present this is useless.

max_depth 1..2, :function

*block*, each following rule_method is initialized to some integer
given by your block upon a call to drp_init, i.e. when you initialize
your extended object instance. the formal parameters to your supplied
block are counted, and the appropriate number of codons harvested using
InstanceMethods#next_meta_codon are passed to the block.

max_depth { |next_meta_codon, ...| ... }
                         
=end


  def weight *args, &block
    bg, are_args = block_given?, args.size > 0
    if bg && are_args
      raise ArgumentError, 'weight called with both arguments and a block', caller
    elsif bg
      @__drp__weights << Weights::ProcStaticWeight.factory(block)
    elsif are_args
      @__drp__weights << Weights::StaticWeight.factory(args)
    else
      raise ArgumentError, 'weight called with neither args nor block', caller
    end 
  end

=begin NOT REALLY USEFUL
  def weight_dyn *args, &block
    bg, are_args = block_given?, args.size > 0
    if bg && are_args
      __drp__error "weight_dyn called with both args and block"
    elsif bg
      @__drp__weights << Weights::ProcDynamicWeight.factory(block)
    elsif are_args
      @__drp__weights << Weights::DynamicWeight.factory(args)
    else
      raise ArgumentError, 'weight_dyn called with neither args nor block', caller
    end 
  end
=end

  def weight_fcd *args, &block
    bg, are_args = block_given?, args.size > 0
    if bg && are_args
      __drp__error "weight_fcd called with both args and block"
    elsif bg
      @__drp__weights << Weights::ProcWeightFromCurrentDepth.factory(block)
    elsif are_args
      @__drp__weights << Weights::WeightFromCurrentDepth.factory(args)
    else
      raise ArgumentError, 'weight_fcd called with neither args nor block', caller
    end 
  end

end # class RuleEngine

end # module DRP
