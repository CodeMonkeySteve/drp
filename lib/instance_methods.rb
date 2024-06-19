
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

  module InstanceMethods

    # this is called when all rule methods are exhausted
    # during the selection process. by default returns nil.
    # you can override this in your extended class, 
    # but as a regular method
    # not a rule method to have non-nil value returned, but
    # be sure to accept an array of *args or have the arity
    # correct to handle all your rule methods.
    def default_rule_method *args; end

=begin
    # EXTRANEOUS, CAN JUST BE DONE IN :initialize METHOD
    # this is called automatically for you after
    # your objects are initialized but before any codons
    # are used to set weights depths etc..
    # it does nothing by default
    def init_codons; end
=end

    # you should reimplement this method in your
    # extended class, that is unless you want the
    # default behaviour of an endless random stream.
    # this is included mostly for quick testing purposes
    def next_codon
      rand
    end

    # this is what weights and max_depths use to get codons.
    # it defaults to just using next_codon. override it in
    # your extended class to have them use a separate codon stream
    def next_meta_codon
      next_codon
    end

    # how deep is the current rule method's recursion
    def depth
      @__drp__depth__stack.last
    end

    # what is the maximum depth attainable by the current rule method.
    # do not confuse this with the class method setter
    def max_depth
      @__drp__rule__method__stack.last.max_depth
    end

    # don't know if these two are really worth implementing 
    # how many time has the current rule method executed
    # including this execution
    #def count
    #  @__drp__count__stack.last
    #end
    # how many times has the current rule (all rule methods) 
    # executed including this execution
    # def rule_count
    # end
    
    # uses next_codon to output to somewhere within the range
    # specified using specified function, unless a block is given
    # in which case it counts the formal parameters to the block,
    # and yields appropriate number of codons using next_codon
    # you may not pass both a block and a range, only one or the other
    def map rng = nil, function = :linear, &b # :yields: next_codon ... 
      if block_given?
        if rng
          raise ArgumentError, "both block and #{rng} passed to map", caller
        end
        arity = b.arity
        case arity
          # these are here, and also ordered, for efficiencies sake
          when 1
            yield next_codon
          when 2
            yield next_codon, next_codon
          when 0, -1
            raise ArgumentError, 'block given to map must have 1 or more arguments', caller
          else
            yield *Array.new(arity) { next_codon }
        end
      else
        Utils::map rng, next_codon, function
      end
    end
    
   private

    def __drp__choose__method useable_methods

      weights = useable_methods.collect do |meth|
        meth.weight
      end
      scale_by = weights.inject(0) do |weight, prev|
        prev + weight
      end

      weights = if scale_by == 0
        sz = weights.size
        weight = 1.0/sz
        prev_weight = 0
        Array.new(sz) do 
          prev_weight = weight + prev_weight
        end
      else
        prev_weight = 0
        weights.collect do |weight|
          prev_weight = weight / scale_by + prev_weight
        end
      end
     
      index, codon = -1, next_codon
      weights.detect do |weight| 
        index += 1;
        codon < weight
      end

      useable_methods[index]

    end

    def __drp__call__method meth, args
      @__drp__depth__stack.push(meth.depth + 1)
      @__drp__rule__method__stack.push meth
      res = meth.call *args
      @__drp__rule__method__stack.pop
      @__drp__depth__stack.pop
      res
    end

  end

end # module DRP
