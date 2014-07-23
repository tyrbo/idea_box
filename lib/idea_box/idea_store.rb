require 'yaml/store'

class IdeaStore
  def self.all
    ideas = []
    raw_ideas.each_with_index do |data, i|
      ideas << Idea.new(data.merge('id' => i))
    end
    ideas
  end

  def self.create(attributes)
    database.transaction do
      database['ideas'] << attributes
    end
  end

  def self.find(id)
    raw_idea = find_raw_idea(id)
    Idea.new(raw_idea.merge('id' => id))
  end

  def self.update(id, data)
    item = merge(find(id), data)
    database.transaction do
      database['ideas'][id] = item.to_h
    end
  end

  def self.delete(position)
    database.transaction do
      database['ideas'].delete_at(position)
    end
  end

  private

  def self.find_raw_idea(id)
    database.transaction do
      database['ideas'].at(id)
    end
  end

  def self.raw_ideas
    database.transaction do |db|
      db['ideas'] || []
    end
  end

  def self.merge(item, data)
    data.each_pair do |k, v|
      if item.respond_to?(k)
        item.send("#{k}=", v)
      end
    end
    item
  end

  def self.database
    return @database if @database

    @database = YAML::Store.new 'db/ideabox'
    @database.transaction do
      @database['ideas'] ||= []
    end
    @database
  end
end
