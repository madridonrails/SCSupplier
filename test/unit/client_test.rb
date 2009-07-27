require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "invalid with empty attributes" do
    client = Client.new
    assert !client.valid?
    assert client.errors.invalid?(:client_name)
  end
end
