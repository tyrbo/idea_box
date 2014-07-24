require 'yaml/store'

class UserStore < Store
  def self.all
    users = []
    raw.each_pair do |_, v|
      users << User.new(v)
    end
    users
  end

  def self.exists?(username)
    database.transaction do
      database['users'].any? { |_, x| x['username'] == username }
    end
  end

  def self.find(id)
    raw_user = find_raw_obj(id)
    User.new(raw_user) if raw_user
  end

  def self.login(params)
    database.transaction do
      user = database[table].detect do |_, v|
        v['username'] == params['username'] &&
        v['password'] == params['password']
      end
      User.new(user.last) if user
    end
  end

  private

  def self.table
    'users'
  end
end
