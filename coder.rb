# frozen_string_literal: true

# En/Decoder class for lwe
class Coder
  # Default constructor
  # @param modulo_q [Integer] The modulo used in the scheme
  def initialize(modulo_q)
    @modulo_q = modulo_q
  end

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
end
