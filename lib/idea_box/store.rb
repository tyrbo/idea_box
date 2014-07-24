class Store
  def self.init(path = 'db/ideabox')
    @database = YAML::Store.new path
    @database.transaction do
      @database["#{table}_counter"] ||= 0
      @database[table] ||= {}
    end
  end
  
  def self.create(attributes)
    id = current_id
    database.transaction do
      attributes['id'] = id
      database[table][id] = attributes
      database["#{table}_counter"] = id + 1
    end
  end
  
  def self.clear
    database.transaction do
      database[table] = {}
      database["#{table}_counter"] = 0
    end
  end
  
  def self.update(item, data)
    item.merge(data)
    database.transaction do
      database[table][item.id] = item.to_h
    end
  end

  def self.delete(position)
    database.transaction do
      database[table].delete(position)
    end
  end

  def self.current_id
    database.transaction do
      database["#{table}_counter"] || 0
    end
  end

  private
  
  def self.table
    'private'
  end

  def self.database
    if @database
      @database
    else
      init
      @database
    end
  end

  def self.raw
    database.transaction do
      database[table] || {}
    end
  end

  def self.find_raw_obj(id)
    database.transaction do
      database[table][id]
    end
  end
end
