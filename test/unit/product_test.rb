require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "invalid with empty attributes" do
    
    product = Product.new
    assert !product.valid?
    assert product.errors.invalid?(:name)
    assert product.errors.invalid?(:reference)
    assert product.errors.invalid?(:stock)
  end

  test "stock tests" do

    product = Product.new(:name => 'name', :reference => 'reference')
    product.valid?
    product.errors.invalid?(:stock)
    product.stock = 0
    product.valid?
    assert !product.errors.invalid?(:stock)
    product.stock = 10
    product.valid?
    assert !product.errors.invalid?(:stock)
    product.stock = -1
    product.valid?
    assert product.errors.invalid?(:stock)
    
  end

end
