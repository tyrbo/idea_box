require_relative 'test_helper'

describe IdeaBoxApp do
  include Rack::Test::Methods

  def app
    IdeaBoxApp.new
  end

  def setup
    IdeaStore.init('db/ideabox_test')
    UserStore.init('db/users_test')
    IdeaStore.clear
    UserStore.clear
  end

  def teardown
    #IdeaStore.clear
    #UserStore.clear
  end

  describe 'get /' do
    it 'returns no ideas with an empty database' do
      get '/'
      html = Nokogiri::HTML(last_response.body)

      assert last_response.ok?
      assert_equal 0, html.css('.list-group-item').size
    end

    it 'returns a list of ideas with a populated database' do
      IdeaStore.create('title' => 'Test 1', 'description' => 'Just a test')
      IdeaStore.create('title' => 'Test 2', 'description' => 'Another test')

      get '/'
      html = Nokogiri::HTML(last_response.body)

      assert last_response.ok?
      assert_equal 2, html.css('.list-group-item').size
    end
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

  describe 'post /sms' do
    it 'creates an idea from sms data' do
      post '/sms', :Body => 'My title, And my description'

      idea = IdeaStore.find(0)
      assert_equal 'My title', idea.title
      assert_equal 'And my description', idea.description
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

  describe 'post /users/new' do
    it 'creates a new user' do
      post '/users/new', user: { username: 'test', password: 'test' }

      assert_equal 1, UserStore.all.count
    end

    it 'should redirect after user creation' do
      post '/users/new', user: { username: 'test', password: 'test' }

      assert last_response.redirect?
      follow_redirect!
      assert last_response.ok?
    end
  end

  describe 'post /login' do
    it 'allows a user to log in' do
      user = User.new('username' => 'test', 'password' => 'test')
      UserStore.create(user.to_h)

      post '/login', user: { username: 'test', password: 'test' }
      follow_redirect!
      assert last_response.ok?
      html = Nokogiri::HTML(last_response.body)

      assert last_response.ok?
      assert_equal 'Welcome, test', html.at_css('span#username').text
    end
  end

  describe 'get /logout' do
    it 'logs a user out' do
      user = User.new('username' => 'test', 'password' => 'test')
      UserStore.create(user.to_h)

      post '/login', user: { username: 'test', password: 'test' }
      follow_redirect!
      html = Nokogiri::HTML(last_response.body)
      assert_equal 'Welcome, test', html.at_css('span#username').text

      get '/logout'
      follow_redirect!
      html = Nokogiri::HTML(last_response.body)
      refute html.at_css('span#username')
    end
  end
end
