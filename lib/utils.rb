
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

module Utils

 class << self
 
  def map range, val, function = :linear
    # this line is necessary in case nil is explicitly passed
    function = function ? function.to_sym : :linear
    case function.to_sym

    when :linear, :lin
      linear_map range, val

    when :i_linear, :i_lin
      i_linear_map range, val
    
    else
      raise ArgumentError, "bad function for range: #{function}", caller
    end
  end

 private

  def linear_map range, val
    first, last = range.first, range.last
    diff = last - first
    diff * val + first
  end

  def i_linear_map range, val
    first, last = range.first, range.last
    distance = (last - first).to_i.abs + 1
    i = (distance * val).floor
    if first < last
      first + i
    else
      first - i
    end
  end

 end # class << self

end # module Utils

end # module DRP
