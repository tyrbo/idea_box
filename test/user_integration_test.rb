require_relative 'test_helper'

describe IdeaBoxApp do
  include Rack::Test::Methods
  
  def app
    IdeaBoxApp.new
  end

  def setup
    UserStore.init('db/ideabox_test')
    UserStore.clear
  end

  def teardown
    UserStore.clear
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
