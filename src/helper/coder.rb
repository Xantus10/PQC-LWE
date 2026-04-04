# frozen_string_literal: true

require 'base64'

# En/Decoder class for lwe
class Coder
  # Default constructor
  # @param modulo_q [Integer] The modulo used in the scheme
  def initialize(modulo_q)
    @modulo_q = modulo_q
  end

  private

  # Encode a single bit
  # @param bit [Integer] An integer 0/1
  def encode_bit(bit)
    raise 'Bit must be a 0 or 1' unless [0, 1].include?(bit)

    bit.zero? ? 0 : @modulo_q / 2
  end

  # Decode a single bit
  # @param encoded [Integer] An encoded bit integer
  def decode_bit(encoded)
    raise 'Value is not in range' unless encoded >= 0 && encoded < @modulo_q

    encoded >= @modulo_q / 4 && encoded <= 3 * @modulo_q / 4 ? 1 : 0
  end

  # Encode bytes to bits
  # @param bytes [String] The byte string
  # @return [Array<Integer>] Array of 0/1 values
  def to_bits(bytes)
    b = bytes.unpack1('B*')
    raise 'Bytes did not unpack to String' unless b.is_a? String

    b.each_char.map(&:to_i)
  end

  # Encode bits to bytes
  # @param bits [Array<Integer>] The bits
  # @return [String] The byte string
  def from_bits(bits)
    bytes = bits.each_slice(8).map { |slice| slice.join.to_i(2) }
    bytes.pack('C*')
  end

  public

  # Encode the message to an integer array compliant with LWE
  # @param message [String] The message
  # @return [Array<Integer>] The array of integers
  def encode(message)
    to_bits(message).map { |bit| encode_bit(bit) }
  end

  # Decode the integer array from LWE back into the original message
  # @param array [Array<Integer>] The message
  # @return [String] The array of integers
  def decode(array)
    from_bits(array.map { |bit| decode_bit(bit) })
  end

  # Encode string to hex
  # @param str [String] String to encode
  # @return [String] The hex string
  def self.to_hex(str)
    str.bytes.map { |byte| byte.to_s(16).rjust(2, '0') }.join
  end

  # Encode string to base64
  # @param str [String] String to encode
  # @return [String] The base64 string
  def self.to_base64(str)
    Base64.strict_encode64(str)
  end

  # Decode hex to string
  # @param str [String] String to decode
  # @return [String] The result string
  def self.from_hex(str)
    [str].pack('H*')
  end

  # Decode base64 to string
  # @param str [String] String to decode
  # @return [String] The result string
  def self.from_base64(str)
    Base64.strict_decode64(str)
  end

  # Convert an integer array (2 byte wide integer) to string
  # @param arr [Array<Integer>] The integer array
  # @return [String] The byte string
  def self.str_from_2byte_int_arr(arr)
    arr.pack('s>*')
  end

  # Convert a bytestring to integer array (2 byte wide integer)
  # @param string [String] The byte string
  # @return [Array<Integer>] The integer array
  def self.str_to_2byte_int_arr(string)
    string.bytes.each_slice(2).map { |high, low| high << 8 | low }
  end
end
