class Idea
  include Comparable

  attr_accessor :title, :description
  attr_reader :likes, :dislikes, :id

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

  def merge(data)
    data.each_pair do |k, v|
      if respond_to?("#{k}=")
        send("#{k}=", v)
      end
    end
    self
  end

  def to_h
    {
      'id' => id,
      'title' => title,
      'description' => description,
      'likes' => likes,
      'dislikes' => dislikes
    }
  end

  private

  def <=>(other)
    other.rank <=> rank
  end
end
