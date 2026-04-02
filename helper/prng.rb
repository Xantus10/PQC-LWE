# frozen_string_literal: true

require 'openssl'

# Pseudo RNG
class PRNG
  KEY_SIZE = 32
  BLOCK_SIZE = 16
  DF_SIZE = KEY_SIZE + BLOCK_SIZE

  # Default constructor
  # @param seed [String] The seed for PRNG
  def initialize(seed)
    seed = run_df(seed)

    @key = "\x00".b * KEY_SIZE
    @v = "\x00".b * BLOCK_SIZE

    update(seed)
  end

  private

  # Update @key and @v with provided data
  # @param data [String] Some data
  def update(data)
    raise '@v is nil' if @v.nil?

    new = +''
    while new.bytesize < DF_SIZE
      increment_v!
      new += encrypt_block(@v)
    end

    pd = "\x00".b * (DF_SIZE - data.size)

    new = new.bytes.zip((pd + data).bytes).map { |x, y| x ^ y }.pack('C*')

    @key = new.byteslice(0, KEY_SIZE)
    @v = new.byteslice(KEY_SIZE, BLOCK_SIZE)
  end

  # Encrypt a block with AES
  # @param data [String] The block to encrypt
  def encrypt_block(data)
    raise 'Invalid block size' unless data.size == BLOCK_SIZE
    raise '@key is nil' if @key.nil?

    cipher = OpenSSL::Cipher.new('AES-256-CBC')
    cipher.encrypt
    cipher.key = @key
    cipher.padding = 0
    cipher.update(data) + cipher.final
  end

  # Run the derivation function on the specified input
  # @param input [String] The input to DF
  # @return [String] The DF output of DF_SIZE length
  def run_df(input)
    OpenSSL::KDF.hkdf(input, salt: 'ML**SALT-123()[]'.b, info: 'ML KEM Pseudo RNG'.b, length: DF_SIZE, hash: 'SHA256')
  end

  # Increment the V
  def increment_v!
    raise '@v is nil' if @v.nil?

    bytearray = @v.bytes
    i = 0
    loop do
      i -= 1
      bytearray[i] += 1
      bytearray[i] %= 256
      break unless bytearray[i].zero? && i != -bytearray.size
    end
  end

  public

  # Generate a number of pseudorandom bytes
  # @param n_bytes [Integer] The length of the output
  # @return [String] The pseudorandom bytes
  def generate_bytes(n_bytes)
    raise '@v is nil' if @v.nil?

    output = +''
    while output.bytesize < n_bytes
      increment_v!
      output += encrypt_block(@v)
    end
    update("\x00" * DF_SIZE)
    output = output.byteslice(0, n_bytes)
    output.nil? ? '' : output
  end
end
