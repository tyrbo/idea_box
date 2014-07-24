require_relative 'test_helper'

describe User do
  it 'can create a new user' do
    user = User.new('username' => 'test', 'password' => 'test', 'phone_number' => '720-232-6001')
    assert_equal 'test', user.username
    assert_equal '720-232-6001', user.phone_number
    assert user.password.start_with?('$2a$10$')
  end
end
