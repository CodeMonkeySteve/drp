
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

module MaxDepths

# the max_depth classes are stored in class variables
# and are passed an instance of the extended user class
# so that they can ask for codons if they need them.
# they need not be copied like weights because they are 
# only run once at instance initialization

class StaticMaxDepth
  def initialize int
    @value = int.to_i
  end
  def value drp_instance_unused
    @value
  end
end

class MappedMaxDepth
  def initialize range, function = :i_linear
    @range, @function = range, function
  end
  def value drp_instance
    Utils::map(
      @range,
      drp_instance.next_meta_codon,
      @function
    )
  end
end

class ProcMaxDepth
  def initialize proc
    @proc, @arity = proc, proc.arity
  end
  def value drp_instance
    if @arity <= 0
      @proc.call.to_i
    elsif @arity == 1
      @proc.call(drp_instance.next_meta_codon).to_i
    else
      @proc.call(*Array.new(@arity) { drp_instance.next_meta_codon }).to_i
    end
  end
end

end # module MaxDepths

module Weights

# user args can be array or proc
WeightArgs = Struct.new :user_args, :rule_method, :drp_instance

class AbstractWeight
  def self.factory args_or_proc
    proc do |rule_method, drp_instance|
      self.new WeightArgs.new(args_or_proc, rule_method, drp_instance)
    end
  end
end

=begin
  weight 10.0                         static weight
  weight 0..1                         static mapped
  weight 0..1, :function              static mapped w/ function
  weight {}                           static proc gets codons
=end

class StaticWeight < AbstractWeight
  attr_reader :value
  def initialize args
    user_args = args.user_args
    sz = user_args.size
    case sz
      when 1
        arg = user_args[0]
        case arg
          when Numeric
            @value = arg.to_f
          when Range
            @value = Utils::map(
              arg, 
              args.drp_instance.next_meta_codon
            )
          else 
            raise ArgumentError, 'when 1 arg given to weight, must be Numeric, or Range', caller
        end
      when 2
        rng = args[0] 
        func = args[1].to_sym
        if (rng.kind_of? Range) && (func.kind_of? Symbol)
          @value = Utils::map(
            rng, 
            args.drp_instance.next_meta_codon,
            func
          )
        else
          raise ArgumentError, 'weight args of wrong types'
        end
      else
      raise ArgumentError, "weight takes 1 or 2 args, #{sz} given"
    end # case user_args.size
  end # def initialize
end

class ProcStaticWeight < StaticWeight
  def initialize args
    proc = args.user_args
    ar = proc.arity
    inst = args.drp_instance
    if ar <= 0
      @value = proc.call
    elsif ar == 1
      @value = proc.call inst.next_meta_codon
    else
      @value = proc.call *Array.new(ar) { inst.next_meta_codon }
    end
  end
end

=begin
  weight_dyn 0..1                     codon maps to range for every rule method choice
  weight_dyn 0..1, :function          same but using function
  weight_dyn 0..1, 0..1               initial min and max determined by metacodons
                                        and further runtime mapping also
  weight_dyn 0..1, 0..1, :function    same but function used for runtime mapping
  weight_dyn { |codon| }              same but using use block, gets meta_codons
=end

=begin DYNAMIC WEIGHTS PROBABLY NOT THAT USEFUL 

class DynamicWeight < AbstractWeight 
  def initialize args
    @drp_instance = args.drp_instance
    arg1, arg2, arg3 = args.user_args
    if arg1.kind_of? Range
      @range = arg1
      if arg2.kind_of? Range
        if (arg3.kind_of? Symbol) or (arg3.kind_of? String)
          @function = arg3
        end
        min = Utils::map(@range, @drp_instance.next_meta_codon)
        max = Utils::map(arg2, @drp_instance.next_meta_codon)
        @range = min..max
      elsif (arg2.kind_of? Symbol) or (arg2.kind_of? String)
        @function = arg2
      end
    else
      raise ArgumentError, 'weight_dyn args of wrong type'
    end
  end
  def value
    val = Utils::map(
      @range, 
      @drp_instance.next_meta_codon,
      @function
    )
    puts val
    val
  end
end

class ProcDynamicWeight < AbstractWeight
  def initialize args
    @proc = args.user_args
    @arity = @proc.arity
    @drp_instance = args.drp_instance
  end
  def value
    case @arity
        # these are here, and also ordered, for efficiencies sake
      when 1
        @proc.call @drp_instance.next_meta_codon
      when 2
        @proc.call @drp_instance.next_meta_codon, @drp_instance.next_meta_codon
      when 0
        raise ArgumentError, "block given to dynamic weight must have 1 or more arguments"
      else
        @proc.call *Array.new(@arity) { @drp_instance.next_meta_codon }
    end
  end
end

=end

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

class WeightFromCurrentDepth < AbstractWeight
  def initialize args
    @drp_instance = args.drp_instance
    @rule_method = args.rule_method
    @max_depth = @rule_method.max_depth - 1
    arg1, arg2, arg3 = args.user_args
    if arg1.kind_of? Range
      @range = arg1
      if arg2.kind_of? Range
        if (arg3.kind_of? Symbol) or (arg3.kind_of? String)
          @function = arg3
        end
        min = Utils::map(@range, @drp_instance.next_meta_codon)
        max = Utils::map(arg2, @drp_instance.next_meta_codon)
        @range = min..max
      elsif (arg2.kind_of? Symbol) or (arg2.kind_of? String)
        @function = arg2
      end
    else
      raise ArgumentError, 'bad argument to weight_fcd'
    end    
  end
  def value
    val = @rule_method.depth.to_f / @max_depth
    Utils::map(@range, val, @function)
  end
end

class ProcWeightFromCurrentDepth < AbstractWeight
  def initialize args
    @rule_method = args.rule_method
    @proc = args.user_args.call @rule_method.max_depth
  end
  def value
    @proc.call @rule_method.depth
  end
end

end # module Weights

end # module DRP
