# frozen_string_literal: true

require_relative 'math_helper'
require_relative 'random_helper'
require_relative 'vector'

# LWE algorithm for public key cryptography
class LWE
  # Default constructor
  # @param dimensions_n [Integer] The dimensions of the vectors
  # @param modulo_q [Integer] The domain of integers
  def initialize(dimensions_n, modulo_q)
    @dimensions = dimensions_n
    @modulo = modulo_q

    @secret = RandomHelper.random_vector(dimensions_n)

    @public_matrix = dimensions_n.times.map { RandomHelper.random_vector(dimensions_n) }

    @public_vector = compute_public_vector
  end

  def compute_public_vector
    MathHelper.matrix_vector_multiplication(@public_matrix, @secret) + RandomHelper.random_vector
  end

  # Get the public key
  # @return [Hash{:matrix => Array<Vector>, :vector => Vector
  # }]
  def public_key
    {
      matrix: @public_matrix,
      vector: @public_vector
    }
  end
end
