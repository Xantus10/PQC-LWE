# frozen_string_literal: true

# Class for vector/intarray operations
class Vector
  # Default constructor
  # @param values [Array<Integer>] The values in the vector
  def initialize(values = [])
    @values = values
  end

  attr_reader :values

  # Create a vector formed as vec1[i]+vec2[i]
  # @param other [Vector] Second vector
  # @return [Vector] The result vector
  def +(other)
    raise 'Arrays must have the same size' unless @values.size == other.size

    Vector.new(@values.zip(other.values).map { |i1, i2| i1 + i2 })
  end

  # Create a vector formed as vec1[i]-vec2[i]
  # @param other [Vector] Second vector
  # @return [Vector] The result vector
  def -(other)
    raise 'Arrays must have the same size' unless @values.size == other.size

    Vector.new(@values.zip(other.values).map { |i1, i2| i1 - i2 })
  end

  # Create a vector formed as vec1[i]*vec2[i]
  #
  # This is NOT the DOT product
  # @param other [Vector] Second vector
  # @return [Vector] The result vector
  def *(other)
    raise 'Arrays must have the same size' unless @values.size == other.size

    Vector.new(@values.zip(other.values).map { |i1, i2| i1 * i2 })
  end

  # Compute the dot product between two vectors
  # @param other [Vector] Second vector
  # @return [Integer] The dot product
  def dot_product(other)
    raise 'Vectors must have same size to compute dot product' unless @values.size == other.size

    (self * other).values.sum
  end

  # Wrapper for @values.size
  # @return [Integer] The order of the vector
  def size
    @values.size
  end
end
