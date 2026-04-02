# frozen_string_literal: true

require_relative 'helper/random_helper'
require_relative 'helper/vector'
require_relative 'helper/coder'

# LWE algorithm for public key cryptography
class LWE
  # Default constructor
  # @param dimensions_n [Integer] The dimensions of the vectors
  # @param modulo_q [Integer] The domain of integers
  # @param public_matrix [Matrix] The public matrix (For encapsulation)
  # @param public_vector [Vector] The public vector (For encapsulation)
  def initialize(dimensions_n, modulo_q, public_matrix = nil, public_vector = nil)
    # Dimensions of the vectors
    @dimensions = dimensions_n
    # Modulus
    @modulo = modulo_q

    # Coder object for encoding
    @coder = Coder.new(modulo_q)

    # Secret private vector
    @secret = RandomHelper.random_small_vector(dimensions_n)

    # The matrix from public key, transposed for encapsulation
    @public_matrix = public_matrix.nil? ? RandomHelper.random_matrix(dimensions_n) : public_matrix.transposed

    # The computed vector from public key
    @public_vector = public_vector.nil? ? compute_public_vector(@secret) : public_vector
  end

  private

  # Compute the public vector
  # @param [Vector] secret The secret
  # @return [Vector] The public vector
  def compute_public_vector(secret)
    # vector = matrix * secret + error
    (@public_matrix * secret +
      RandomHelper.random_small_vector(@dimensions)) % @modulo
  end

  public

  # Get the public key
  # @return [Hash]
  # @option return [Matrix] :matrix The public matrix
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
    # Encode into scaled bits
    @coder.encode(message).map do |bit|
      # The temporary key r
      ephemeral = RandomHelper.random_small_vector(@dimensions)
      # The computed encryption key u
      key = compute_public_vector(ephemeral)
      # The ciphertext v
      ciphertext = (ephemeral.dot_product(@public_vector) +
        RandomHelper.random_small_int + bit) % @modulo
      {
        key: key,
        ciphertext: ciphertext
      }
    end
  end

  # Decapsulate the message
  # @param encapsulated [Array<Hash>] The encapsulated message, should follow the same structure
  # @return [String] The original message
  def decapsulate(encapsulated)
    return nil if encapsulated.empty?

    original = []

    encapsulated.each do |enc_bit|
      raise 'Decapsulating: property \':key\' is not Vector' unless enc_bit[:key].is_a?(Vector)
      raise 'Decapsulating: property \':ciphertext\' is not Integer' unless enc_bit[:ciphertext].is_a?(Integer)

      original.push(
        # v - u.s
        (enc_bit[:ciphertext] - @secret.dot_product(enc_bit[:key]) % @modulo) % @modulo
      )
    end

    @coder.decode(original)
  end
end
