class Idea
  include Comparable

  attr_accessor :title, :description, :rank, :id, :likes, :dislikes

  def initialize(data)
    @title = data['title']
    @description = data['description']
    @id = data['id']
    @likes = data['likes'] || 0
    @dislikes = data['dislikes'] || 0
  end

  def rank
    likes - dislikes
  end

  def like!
    @likes += 1
  end

  def dislike!
    @dislikes += 1
  end

  def to_h
    {
      'title' => title,
      'description' => description,
      'likes' => likes,
      'dislikes' => dislikes
    }
  end

  def <=>(other)
    rank <=> other.rank
  end
end
