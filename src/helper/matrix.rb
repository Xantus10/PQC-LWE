# frozen_string_literal: true

require_relative 'vector'

# Class for matrix
class Matrix
  # Default constructor
  # @param values [Array<Array<Integer>>] The 2D values in the matrix
  def initialize(values = [])
    @values = values
  end

  attr_reader :values

  # Return a transposed matrix
  # @return [Matrix] The transposed matrix
  def transposed
    Matrix.new(@values.transpose)
  end

  # Matrix-Vector multiplication
  # @param other [Vector] The other vector
  # @return [Vector] The result vector
  def *(other)
    raise 'Matrix is empty' if @values.empty?
    raise 'Matrix width has to align with vector size' unless @values.size == other.size

    Vector.new(@values.map { |row| Vector.new(row).dot_product(other) })
  end
end
