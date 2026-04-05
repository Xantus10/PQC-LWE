# frozen_string_literal: true

require_relative 'helper/constants'
require_relative 'helper/random_helper'
require_relative 'helper/polynomial'
require_relative 'helper/coder'

# Ring LWE algorithm for public key cryptography
class RingLWE
  # Default constructor
  # @param dimensions_n [Integer] The dimensions of the vectors
  # @param modulo_q [Integer] The domain of integers
  # @param polynomial_seed [String] The public polynomial seed (For encapsulation)
  # @param public_polynomial [Polynomial] The public polynomial (For encapsulation)
  def initialize(dimensions_n: Constants::ORDER_N, modulo_q: Constants::MODULUS_Q,
                 polynomial_seed: nil, public_polynomial: nil)
    # Dimensions of the vectors
    @dimensions = dimensions_n
    # Modulus
    @modulo = modulo_q

    # Coder object for encoding
    @coder = Coder.new(modulo_q)

    # Secret private polynomial
    @secret = RandomHelper.random_small_polynomial(dimensions_n)

    # Seed for polynomial generation
    @seed = polynomial_seed || RandomHelper.random_key(32)
    # The pseudorandom polynomial from public key
    @public_pseudo_polynomial = RandomHelper.pseudorandom_polynomial(dimensions_n, @seed)
    # The computed polynomial from public key
    @public_polynomial = public_polynomial || compute_public_polynomial(@secret)
  end

  private

  # Compute the public polynomial
  # @param [Polynomial] secret The secret
  # @return [Polynomial] The public polynomial
  def compute_public_polynomial(secret)
    # b = as + e
    (Polynomial.ntt_multiply(@public_pseudo_polynomial, secret) +
      RandomHelper.random_small_polynomial(@dimensions))
  end

  public

  # Get the public key
  # @return [Hash]
  # @option return [String] :seed The public pseudorandom polynomial seed
  # @option return [Polynomial] :polynomial The public polynomial
  def public_key
    {
      seed: @seed,
      polynomial: @public_polynomial
    }
  end

  SERIALIZATION_ENCODERS = {
    hex: ->(str) { Coder.to_hex(str) },
    base64: ->(str) { Coder.to_base64(str) },
    raw: ->(str) { str }
  }.freeze

  # Serialize the public key
  # @param encoding [Symbol] Supported encodings are :raw, :hex and :base64
  # @return [String] The serialized public key
  def serialized_public_key(encoding: :hex)
    serialized = @seed + @public_polynomial.values.pack('s>*')

    SERIALIZATION_ENCODERS.fetch(encoding) { raise 'Encoding not supported' }.call(serialized)
  end

  # Get the public key
  # @param serialized [String] Serialized public key
  # @return [Hash]
  # @option return [String] :seed The public pseudorandom polynomial seed
  # @option return [Polynomial] :polynomial The public polynomial
  def self.deserialize_public_key(serialized)
    if serialized.size == (32 + 512) * 2
      serialized = Coder.from_hex(serialized)
    elsif serialized.size != 32 + 512
      serialized = Coder.from_base64(serialized)
    end

    {
      seed: serialized.byteslice(0, 32),
      polynomial: Polynomial.new(Coder.str_to_2byte_int_arr(serialized.byteslice(32, 512) || ''))
    }
  end

  # Create RLWE instance from serialized public key
  # @param serialized [String] Serialized public key
  # @return [RingLWE] RLWE instance
  def self.load_from_serialized_public_key(serialized)
    pub = deserialize_public_key(serialized)
    RingLWE.new(polynomial_seed: pub[:seed], public_polynomial: pub[:polynomial])
  end

  # Encapsulate the message
  #
  # Supports 32 byte strings
  # @param message [String] The message
  # @return [Hash]
  # @option return [Polynomial] :key
  # @option return [Polynomial] :ciphertext
  def encapsulate(message)
    raise 'Message has incorrect length' unless message.bytesize == 32

    # temporary key r
    ephemeral = RandomHelper.random_small_polynomial(@dimensions)
    # computed key u
    key = compute_public_polynomial(ephemeral)
    # ciphertext v
    ciphertext = Polynomial.ntt_multiply(@public_polynomial, ephemeral) +
                 RandomHelper.random_small_polynomial(@dimensions) +
                 Polynomial.new(@coder.encode(message))
    {
      key: key,
      ciphertext: ciphertext
    }
  end

  # Decapsulate the message
  # @param encapsulated [Hash] The encapsulated message, should follow the same structure
  # @return [String] The original message
  def decapsulate(encapsulated)
    return '' if encapsulated.empty?

    @coder.decode((encapsulated[:ciphertext] - Polynomial.ntt_multiply(@secret, encapsulated[:key])).values)
  end
end

alice = RingLWE.new

pub = alice.serialized_public_key(encoding: :base64)

puts pub

bob = RingLWE.load_from_serialized_public_key(pub)

enc = bob.encapsulate('Hi AliceHi AliceHi AliceHi Alice')

puts alice.decapsulate(enc)
