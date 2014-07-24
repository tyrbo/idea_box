require_relative 'test_helper'

describe IdeaBoxApp do
  include Rack::Test::Methods
  
  def app
    IdeaBoxApp.new
  end

  def setup
    IdeaStore.init('db/ideabox_test')
    IdeaStore.clear
  end

  def teardown
    IdeaStore.clear
  end

  describe 'get /:item/edit' do
    it 'displays the correct information for an item' do
      IdeaStore.create('title' => 'Proper Title', 'description' => 'Proper Description')
      
      get '/0/edit'
      html = Nokogiri::HTML(last_response.body)

      assert last_response.ok?
      assert_equal 'Proper Title', html.at_css('input#title')['value']
      assert_equal 'Proper Description', html.at_css('textarea#description').text
    end
  end

  describe 'put /:item' do
    it 'updates a given item' do
      IdeaStore.create('title' => 'Original Title', 'description' => 'Original Description')

      put '/0', idea: { title: 'New Title', description: 'New Description' }

      idea = IdeaStore.find(0)
      assert_equal 'New Title', idea.title
      assert_equal 'New Description', idea.description
    end

    it 'redirects after editing an item' do
      IdeaStore.create('title' => 'Original Title', 'description' => 'Original Description')

      put '/0', idea: { title: 'New Title', description: 'New Description' }

      assert last_response.redirect?
      follow_redirect!
      assert last_response.ok?
    end
  end

  describe 'post /:item' do
    it 'creates a new item' do
      post '/', idea: { title: 'New Title', description: 'New Description' }
      
      idea = IdeaStore.find(0)
      assert_equal 'New Title', idea.title
      assert_equal 'New Description', idea.description
    end

    it 'redirects after creation' do
      post '/', idea: { title: 'New Title', description: 'New Description' }
      assert last_response.redirect?
      follow_redirect!
      assert last_response.ok?
    end
  end
  
  describe 'post /:item/like' do
    it 'likes an item' do
      IdeaStore.create('title' => 'Original Title', 'description' => 'Original Description')
      
      post '/0/like'

      idea = IdeaStore.find(0)
      assert_equal 1, idea.likes
    end

    it 'redirects after a like' do
      IdeaStore.create('title' => 'Original Title', 'description' => 'Original Description')
      
      post '/0/like'

      assert last_response.redirect?
      follow_redirect!
      assert last_response.ok?
    end
  end

  describe 'post /:item/dislike' do
    it 'dislikes an item' do
      IdeaStore.create('title' => 'Original Title', 'description' => 'Original Description')
      
      post '/0/dislike'

      idea = IdeaStore.find(0)
      assert_equal 1, idea.dislikes
    end

    it 'redirects after a dislike' do
      IdeaStore.create('title' => 'Original Title', 'description' => 'Original Description')
      
      post '/0/dislike'

      assert last_response.redirect?
      follow_redirect!
      assert last_response.ok?
    end
  end

  describe 'delete /:id' do
    it 'deletes an item' do
      IdeaStore.create('title' => 'Original Title', 'description' => 'Original Description')
      IdeaStore.create('title' => 'Original Title', 'description' => 'Original Description')
      delete '/0'

      assert_equal 1, IdeaStore.all.count
    end
  end
end
