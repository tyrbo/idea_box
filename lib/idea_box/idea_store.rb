require 'yaml/store'

class IdeaStore < Store
  def self.all
    ideas = []
    raw.each_pair do |_, v|
      ideas << Idea.new(v)
    end
    ideas
  end

  def self.find(id)
    raw_idea = find_raw_obj(id)
    Idea.new(raw_idea)
  end

  private

  def self.table
    'ideas'
  end
end
