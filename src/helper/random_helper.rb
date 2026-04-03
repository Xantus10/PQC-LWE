# frozen_string_literal: true

require 'securerandom'

require_relative 'prng'
require_relative 'vector'
require_relative 'matrix'

# Generator for LWE
module RandomHelper
  SMALL_RANGE = 3
  BIG_MAX = 3329

  # Get a random small integer, using centered binominal distribution
  # @return [Integer] Small integer
  def random_small_int
    bits = SecureRandom.random_bytes((2 * SMALL_RANGE + 7) / 8).bytes
                       .map { |byte| byte.to_s(2).rjust(8, '0') }
                       .join[0...SMALL_RANGE * 2]

    # Count bits in first half minus second half
    s1 = bits[0...SMALL_RANGE].count('1')
    s2 = bits[SMALL_RANGE...SMALL_RANGE * 2].count('1')

    s1 - s2
  end

  # Get a vector of specified dimensions and of small integers
  # @param dimensions_n [Integer] The length of the vector
  # @return [Vector] Vector of Small integers
  def random_small_vector(dimensions_n)
    Vector.new(dimensions_n.times.map { random_small_int })
  end

  # Get a matrix of big pseudorandom numbers generated from the seed
  # @param dimensions_n [Integer] The dimensions of the square matrix
  # @param seed [String] The seed for PRNG
  # @return [Matrix] The matrix
  def pseudorandom_matrix(dimensions_n, seed)
    prng = PRNG.new(seed)
    Matrix.new(
      dimensions_n.times.map do
        prng.generate_bytes(dimensions_n).bytes
      end
    )
  end

  # Get a random key material
  # @param size_bytes [Integer] How big should the key be
  # @return [String]
  def random_key(size_bytes)
    SecureRandom.random_bytes(size_bytes)
  end

  module_function :random_small_int, :random_small_vector, :pseudorandom_matrix, :random_key
end
