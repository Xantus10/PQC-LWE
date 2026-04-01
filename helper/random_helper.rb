# frozen_string_literal: true

require 'securerandom'

require_relative 'vector'

# Generator for LWE
module RandomHelper
  SMALL_MIN = -3
  SMALL_MAX = 3
  BIG_MAX = 3000

  # Get a random small integer
  # @return [Integer] Small integer
  def random_small_int
    SMALL_MAX - SecureRandom.random_number(SMALL_MAX - SMALL_MIN + 1)
  end

  # Get a vector of specified dimensions and of small integers
  # @param dimensions_n [Integer] The length of the vector
  # @return [Vector] Vector of Small integers
  def random_small_vector(dimensions_n)
    Vector.new(dimensions_n.times.map { random_small_int })
  end

  # Get a vector of specified dimensions and of normally sized integers
  # @param dimensions_n [Integer] The length of the vector
  # @return [Vector] Vector of Small integers
  def random_vector(dimensions_n)
    Vector.new(dimensions_n.times.map { SecureRandom.random_number(BIG_MAX) })
  end

  # Get an array of random vectors with big numbers (matrix)
  # @param dimensions_n [Integer] The length of the vector and the size of array
  # @return [Array<Vector>] The matrix
  def random_matrix(dimensions_n)
    dimensions_n.times.map { random_vector(dimensions_n) }
  end

  # Get a random key material
  # @param size_bytes [Integer] How big should the key be
  # @return [String]
  def random_key(size_bytes)
    SecureRandom.random_bytes(size_bytes)
  end

  module_function :random_small_int, :random_small_vector, :random_vector, :random_matrix, :random_key
end
