require_relative 'test_helper'

describe IdeaBoxApp do
  include Rack::Test::Methods

  def app
    IdeaBoxApp.new
  end

  def setup
    IdeaStore.init('db/ideabox_test')
    UserStore.init('db/ideabox_test')
    IdeaStore.clear
    UserStore.clear
  end

  def teardown
    IdeaStore.clear
    UserStore.clear
  end

  describe 'get /' do
    it 'returns no ideas with an empty database' do
      get '/'
      html = Nokogiri::HTML(last_response.body)

      assert last_response.ok?
      assert_equal 0, html.css('.list-group-item').size
    end

    it 'returns a list of ideas with a populated database' do
      user = User.new('username' => 'test', 'password' => 'test', 'id' => 0)
      IdeaStore.create({ 'title' => 'Test 1', 'description' => 'Just a test' }, user)
      IdeaStore.create({ 'title' => 'Test 2', 'description' => 'Another test' }, user)

      get '/'
      html = Nokogiri::HTML(last_response.body)

      assert last_response.ok?
      assert_equal 2, html.css('.list-group-item').size
    end
  end

  describe 'post /sms' do
    it 'creates an idea from sms data' do
      user = User.new('username' => 'test', 'password' => 'test', 'phone_number' => '720-232-6001', 'id' => 0)
      UserStore.create(user.to_h)

      post '/sms', :Body => 'My title, And my description', :From => '720-232-6001'

      idea = IdeaStore.find(0)
      assert_equal 'My title', idea.title
      assert_equal 'And my description', idea.description
    end
  end
end
