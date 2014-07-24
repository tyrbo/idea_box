require 'bcrypt'

class User
  include BCrypt

  attr_reader :username, :password, :id

  def initialize(attributes)
    @id = attributes['id']
    @username = attributes['username']
    @password = Password.create(attributes['password'])
  end

  def to_h
    {
      'id' => id,
      'username' => username,
      'password' => password
    }
  end
end
