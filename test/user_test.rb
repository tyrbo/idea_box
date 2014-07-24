require_relative 'test_helper'

describe User do
  it 'can create a new user' do
    user = User.new('username' => 'test', 'password' => 'test')
    assert_equal 'test', user.username
    assert user.password.start_with?('$2a$10$')
  end
end
