
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
module SearchAlgorithms
module PSO

VERY_LARGE_NUMBER = 2**29

class AbstractParticleSwarmOptimizer

  attr_reader :global_best_error, :global_best_vector

  def initialize swarm_size, vector_size
    @swarm_size, @vector_size = swarm_size, vector_size
  end

 private

  # must be called by subclass initialize methods
  def init_particles particle_class
    @particles = Array.new(@swarm_size) { particle_class.new(self,@vector_size) }
    set_as_global_best @particles[rand(@swarm_size)] 
  end

  def set_as_global_best particle
    @global_best_vector = particle.vector.dup
  end

end

class InteractiveParticle

  attr_accessor :vector

  def initialize pso, vector_size
    @pso, @vector_size = pso, vector_size
    init_vector
  end

  def set_as_best
    @best_vector = @vector.dup
  end
  def set_as_global_best
    @pso.set_as_global_best self
  end

  def roam
    gbest = @pso.global_best_vector
    @vector_size.times do |i|
      c = @vector[i]
      pbest = @best_vector[i]
      @vector[i] = c + 2 * rand * pbest - c + 2 * rand * gbest[i] - c
    end
  end

  def init_vector 
    @vector = Array.new(@vector_size) { rand }
    set_as_best
  end

=begin
  def save name
    
  end
  def load name
    if @thawed
      # ...
    end
  end

  def freeze; @thawed = false end
  def thaw; @thawed = true end
  def frozen? !@thawed end
=end
end

class InteractiveParticleSwarmOptimizer < AbstractParticleSwarmOptimizer

  attr_reader :particles

  def initialize swarm_size, vector_size, rebirth = 0.0
    super
    init_particles InteractiveParticle
  end
  def each
    @particles.each do |p|
      yield p
    end
  end
  def roam_all
    each { |p| p.roam }
  end
  def reinit_all
    each { |p| p.init_vector }
  end

end

class Particle < InteractiveParticle
  def initialize pso, vector_size
    @best_error = VERY_LARGE_NUMBER
    super
  end
  def optimize error
    if error < @best_error
      @best_error = error
      set_as_best
    end
  end
end

class ParticleSwarmOptimizer < AbstractParticleSwarmOptimizer

  def initialize swarm_size, vector_size, rebirth = 0.0
    @global_best_error = VERY_LARGE_NUMBER
    @num_reborn = (swarm_size * rebirth).to_i
    @rebirth_index = 0
    super swarm_size, vector_size
    init_particles Particle    
  end

  def each
    rebirth
    best_this_time = VERY_LARGE_NUMBER
    @particles.each do |p|
      v = p.vector
      error = yield v
      if error < @global_best_error
        @global_best_vector = v.dup
        @global_best_error = error
      end
      if error < best_this_time
        best_this_time = error
      end
      p.optimize error
      p.roam
    end
    #puts best_this_time
  end

 private

  # my non-standard addition to pso algorithm
  # the idea being brutal removal from local optima.
  # cycles through particles to give the reborn
  # a chance to roam a bit before being reborn yet again.
  def rebirth
    @num_reborn.times do
      @rebirth_index = 0 if @rebirth_index == @swarm_size
      @particles[@rebirth_index].init_vector
      @rebirth_index += 1
    end 
  end

end

end # module PSO
end # module SearchAlgoritms
end # module DRP
