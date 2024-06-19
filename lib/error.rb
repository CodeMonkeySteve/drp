
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

class DRPError < StandardError
end

class DRPNameClashError < DRPError

  CLASHING_INSTANCE_METHODS = %w{
    # default_rule_method 
    # next_codon
    # next_meta_codon
    depth
    max_depth
    map
  }
  CLASHING_CLASS_METHODS = %w{
    begin_rules
    end_rules
    max_depth
    weight
    weight_fcd
  }

  def self.test extended_klass
    k = extended_klass
    CLASHING_INSTANCE_METHODS.each do |m|
      if k.method_defined?(m) or k.protected_method_defined?(m) or k.private_method_defined?(m)
        raise(
          self,
          "the class you are extending already defines instance method '#{m}'",
          caller
        )
      end
    end
    class_methods = k.methods + k.protected_methods + k.private_methods
    CLASHING_CLASS_METHODS.each do |name|
      if class_methods.include? name
        raise(
          self,
          "the class you are extending already defines class method #{name}",
          caller
        )
      end
    end
  end
end # DRPNameClashError
   
end # module DRP
