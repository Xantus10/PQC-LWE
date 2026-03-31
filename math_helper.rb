# frozen_string_literal: true

require_relative 'vector'

# Helper functions for mathematical operations
module MathHelper
  # Compute multiplication product between a matrix and a vector
  # @param mat [Array<Vector>] The matrix
  # @param vec [Vector] The vector
  # @return [Vector] The result of multiplication
  def matrix_vector_multiplication(mat, vec)
    raise 'Matrix is empty' if mat.empty?
    raise 'Matrix width has to align with vector size' unless vec.size == mat[0].size

    Vector.new(mat.map { |row| row.dot_product(vec) })
  end

  module_function :matrix_vector_multiplication
end
