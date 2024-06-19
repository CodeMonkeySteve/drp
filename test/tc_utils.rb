
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

# TODO test if the range is of the form n..n where n is the same number

class TestUtils < Test::Unit::TestCase

  def test_i_linear_map

    r = 0..4

    assert_equal 0, DRP::Utils::map(r, 0, :i_linear)
    assert_equal 0, DRP::Utils::map(r, 0.19999, :i_linear)
    assert_equal 1, DRP::Utils::map(r, 0.2, :i_linear)
    assert_equal 1, DRP::Utils::map(r, 0.39999, :i_linear)
    assert_equal 2, DRP::Utils::map(r, 0.4, :i_linear)
    assert_equal 2, DRP::Utils::map(r, 0.59999, :i_linear)
    assert_equal 3, DRP::Utils::map(r, 0.6, :i_linear)
    assert_equal 3, DRP::Utils::map(r, 0.79999, :i_linear)
    assert_equal 4, DRP::Utils::map(r, 0.8, :i_linear)
    assert_equal 4, DRP::Utils::map(r, 0.99999, :i_linear)
    # this is 5 but codons need to be 0 <= c < 1 so it should never happen
    # assert_equal 5, DRP::Utils::map(r, 1, :i_linear)

    r = 4..0

    assert_equal 4, DRP::Utils::map(r, 0, :i_linear)
    assert_equal 4, DRP::Utils::map(r, 0.19999, :i_linear)
    assert_equal 3, DRP::Utils::map(r, 0.2, :i_linear)
    assert_equal 3, DRP::Utils::map(r, 0.39999, :i_linear)
    assert_equal 2, DRP::Utils::map(r, 0.4, :i_linear)
    assert_equal 2, DRP::Utils::map(r, 0.59999, :i_linear)
    assert_equal 1, DRP::Utils::map(r, 0.6, :i_linear)
    assert_equal 1, DRP::Utils::map(r, 0.79999, :i_linear)
    assert_equal 0, DRP::Utils::map(r, 0.8, :i_linear)
    assert_equal 0, DRP::Utils::map(r, 0.99999, :i_linear)

  end
end



