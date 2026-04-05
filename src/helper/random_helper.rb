# frozen_string_literal: true

require 'securerandom'

require_relative 'constants'
require_relative 'coder'
require_relative 'prng'
require_relative 'vector'
require_relative 'matrix'
require_relative 'polynomial'

# Generator for LWE
module RandomHelper
  # Get a random small integer, using centered binominal distribution
  # @return [Integer] Small integer
  def random_small_int
    bits = SecureRandom.random_bytes((2 * Constants::SMALL_RANGE + 7) / 8).bytes
                       .map { |byte| byte.to_s(2).rjust(8, '0') }
                       .join[0...Constants::SMALL_RANGE * 2]

    # Count bits in first half minus second half
    s1 = bits[0...Constants::SMALL_RANGE].count('1')
    s2 = bits[Constants::SMALL_RANGE...Constants::SMALL_RANGE * 2].count('1')

    s1 - s2
  end

  # Get an array filled with random numbers
  # @param dimensions_n [Integer] The length of the array
  # @return [Array<Integer>] The random array
  def random_small_array(dimensions_n)
    dimensions_n.times.map { random_small_int }
  end

  # Get a vector of specified dimensions and of small integers
  # @param dimensions_n [Integer] The length of the vector
  # @return [Vector] Vector of Small integers
  def random_small_vector(dimensions_n)
    Vector.new(random_small_array(dimensions_n))
  end

  # Get a polynomial of specified dimensions and of small integers
  # @param dimensions_n [Integer] The length of the polynomial
  # @return [Polynomial] Polynomial of Small integers
  def random_small_polynomial(dimensions_n)
    Polynomial.new(random_small_array(dimensions_n))
  end

  # Get an array of pseudorandom numbers generated from the seed
  # @param dimensions_n [Integer] The dimensions of the array
  # @param seed [String] The seed for PRNG
  # @return [Array<Integer>] The pseudorandom array
  def pseudorandom_array(dimensions_n, seed)
    prng = PRNG.new(seed)
    Coder.str_to_2byte_int_arr(prng.generate_bytes(dimensions_n * 2)).map { |val| val % Constants::MODULUS_Q }
  end

  # Get a matrix of big pseudorandom numbers generated from the seed
  # @param dimensions_n [Integer] The dimensions of the square matrix
  # @param seed [String] The seed for PRNG
  # @return [Matrix] The matrix
  def pseudorandom_matrix(dimensions_n, seed)
    Matrix.new(
      dimensions_n.times.map do
        pseudorandom_array(dimensions_n, seed)
      end
    )
  end

  # Get a polynomial of pseudorandom numbers generated from the seed
  # @param dimensions_n [Integer] The dimensions of the polynomial
  # @param seed [String] The seed for PRNG
  # @return [Polynomial] The pseudorandom polynomial
  def pseudorandom_polynomial(dimensions_n, seed)
    Polynomial.new(pseudorandom_array(dimensions_n, seed))
  end

  # Get a random key material
  # @param size_bytes [Integer] How big should the key be
  # @return [String]
  def random_key(size_bytes)
    SecureRandom.random_bytes(size_bytes)
  end

  module_function :random_small_int, :random_small_array, :random_small_vector, :random_small_polynomial,
                  :pseudorandom_array, :pseudorandom_matrix, :pseudorandom_polynomial,
                  :random_key
end
