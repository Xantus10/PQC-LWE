# frozen_string_literal: true

require 'openssl'

require_relative 'constants'

require_relative 'vector'

# Class for polynomial representation
class Polynomial
  # Default constructor
  # @param values [Array<Integer>] Array of coefficients (The least significant first)
  # @param modulo [Integer] The numerical modulo for the polynomial
  # @param root_of_unity [Integer] The nth primitive root of unity modulo Q
  def initialize(values, modulo: Constants::MODULUS_Q, root_of_unity: Constants::ROOT_OF_UNITY)
    @values = values
    @modulo = modulo
    @root_of_unity = root_of_unity
  end

  attr_reader :values, :modulo, :root_of_unity

  # Compute the value of the polynomial at some value x
  # @param point [Integer] The point at which to compute
  # @return [Integer] The result
  def polynomial_result_at(point)
    @values.map.with_index { |val, ix| val * point.pow(ix, @modulo) }.sum % @modulo
  end

  # Return the mod inverse of the root_of_unity under modulus
  # @param root_of_unity [Integer] The nth primitive root of unity modulo Q
  # @param modulo [Integer] The numerical modulo for the polynomial
  # @return [Integer] Modular inverse
  def self.root_of_unity_mod_inverse(root_of_unity, modulo)
    OpenSSL::BN.new(root_of_unity).mod_inverse(OpenSSL::BN.new(modulo)).to_i
  end

  # Return a vector containing NTT frequency distribution of this polynomial
  # @return [Vector] The NTT frequency distribution
  def ntt_representation
    Vector.new(@values.size.times.map { |index| polynomial_result_at(@root_of_unity.pow(index, @modulo)) })
  end

  # Add two polynomials
  # @param other [Polynomial] The other polynomial
  # @return [Polynomial] The result polynomial
  def +(other)
    Polynomial.new(@values.zip(other.values).map { |a, b| (a + b) % @modulo },
                   modulo: @modulo, root_of_unity: @root_of_unity)
  end

  # Subtract two polynomials
  # @param other [Polynomial] The other polynomial
  # @return [Polynomial] The result polynomial
  def -(other)
    Polynomial.new(@values.zip(other.values).map { |a, b| (a - b) % @modulo },
                   modulo: @modulo, root_of_unity: @root_of_unity)
  end

  # Multiply two polynomials using NTT
  # @param first [Polynomial] The first polynomial
  # @param other [Polynomial] The other polynomial
  # @return [Polynomial] The result polynomial
  def self.ntt_multiply(first, other)
    ntt1 = first.ntt_representation
    ntt2 = other.ntt_representation
    Polynomial.from_ntt(ntt1 * ntt2, first.modulo, first.root_of_unity)
  end

  # Construct a polynomial from its NTT representation (preforms INTT)
  # @param ntt [Vector] The NTT in vector form
  # @param modulo [Integer] The numerical modulo for the polynomial
  # @param root_of_unity [Integer] The nth primitive root of unity modulo Q
  # @return [Polynomial] The reconstructed polynomial
  def self.from_ntt(ntt, modulo, root_of_unity)
    inv = Polynomial.root_of_unity_mod_inverse(ntt.size, modulo)
    Polynomial.new(Polynomial.new(ntt.values, modulo: modulo, root_of_unity: inv).ntt_representation
                             .values.map { |val| (val * inv) % modulo }, modulo: modulo, root_of_unity: root_of_unity)
  end
end
