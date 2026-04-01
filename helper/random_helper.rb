# frozen_string_literal: true

require 'securerandom'

require_relative 'vector'

# Generator for LWE
module RandomHelper
  SMALL_MIN = -3
  SMALL_MAX = 3

  # Get a random small integer
  # @return [Integer] Small integer
  def random_small_int
    SMALL_MAX - SecureRandom.random_number(SMALL_MAX - SMALL_MIN + 1)
  end

  # Get a vector of specified dimensions and of small integers
  # @param dimensions_n [Integer] The length of the vector
  # @return [Vector] Vector of Small integers
  def random_vector(dimensions_n)
    Vector.new(dimensions_n.times.map { random_small_int })
  end

  # Get a random key material
  # @param size_bytes [Integer] How big should the key be
  # @return [String]
  def random_key(size_bytes)
    SecureRandom.random_bytes(size_bytes)
  end

  module_function :random_small_int, :random_vector, :random_key
end
