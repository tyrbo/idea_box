require 'yaml/store'

class IdeaStore < Store
  def self.all
    ideas = []
    raw.each_pair do |_, v|
      ideas << Idea.new(v)
    end
    ideas
  end
  
  def self.create(attributes, user)
    id = current_id
    database.transaction do
      attributes['id'] = id
      attributes['user_id'] = user.id
      database[table][id] = attributes
      database["#{table}_counter"] = id + 1
    end
    id
  end

  def self.find(id)
    raw_idea = find_raw_obj(id)
    Idea.new(raw_idea) if raw_idea
  end

  private

  def self.table
    'ideas'
  end
end
