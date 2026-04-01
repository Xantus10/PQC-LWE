# frozen_string_literal: true

require_relative 'helper/math_helper'
require_relative 'helper/random_helper'
require_relative 'helper/vector'
require_relative 'helper/coder'

# LWE algorithm for public key cryptography
class LWE
  # Default constructor
  # @param dimensions_n [Integer] The dimensions of the vectors
  # @param modulo_q [Integer] The domain of integers
  # @param public_matrix [Array<Vector>] The public matrix (For encapsulation)
  # @param public_vector [Vector] The public vector (For encapsulation)
  def initialize(dimensions_n, modulo_q, public_matrix = nil, public_vector = nil)
    @dimensions = dimensions_n
    @modulo = modulo_q

    @coder = Coder.new(modulo_q)

    @secret = RandomHelper.random_small_vector(dimensions_n)

    @public_matrix = public_matrix.nil? ? RandomHelper.random_matrix(dimensions_n) : public_matrix

    @public_vector = public_vector.nil? ? compute_public_vector(@secret) : public_vector
  end

  private

  # Compute the public vector
  # @param [Vector] secret The secret
  # @return [Vector] The public vector
  def compute_public_vector(secret)
    (MathHelper.matrix_vector_multiplication(@public_matrix, secret) +
      RandomHelper.random_small_vector(@dimensions)) % @modulo
  end

  public

  # Get the public key
  # @return [Hash]
  # @option return [Array<Vector>] :matrix The public matrix
  # @option return [Vector] :vector The public vector
  def public_key
    {
      matrix: @public_matrix,
      vector: @public_vector
    }
  end

  # Encapsulate the message
  #
  # The primitive LWE supports encryption only bit by bit
  # @param message [String] The message
  # @return [Array<Hash>]
  # @option return [Vector] :key
  # @option return [Integer] :ciphertext
  def encapsulate(message)
    @coder.encode(message).map do |bit|
      ephemeral = RandomHelper.random_small_vector(@dimensions)
      key = compute_public_vector(ephemeral)
      ciphertext = (ephemeral.dot_product(@public_vector) +
        RandomHelper.random_small_int + bit) % @modulo
      {
        key: key,
        ciphertext: ciphertext
      }
    end
  end
end
