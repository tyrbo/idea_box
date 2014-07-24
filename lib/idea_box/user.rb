require 'bcrypt'

class User
  include BCrypt

  attr_reader :username, :password, :id, :phone_number

  def initialize(attributes)
    @id = attributes['id']
    @username = attributes['username']
    @password = Password.create(attributes['password'])
    @phone_number = attributes['phone_number']
  end

  def to_h
    {
      'id' => id,
      'username' => username,
      'password' => password,
      'phone_number' => phone_number
    }
  end
end
