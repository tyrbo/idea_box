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

  describe '/' do
    it 'returns no ideas with an empty database' do
      get '/'
      html = Nokogiri::HTML(last_response.body)

      assert last_response.ok?
      assert_equal 0, html.css('.list-group-item').size
    end

    it 'returns a list of ideas with a populated database' do
      IdeaStore.create(title: 'Test 1', description: 'Just a test')
      IdeaStore.create(title: 'Test 2', description: 'Another test')

      get '/'
      html = Nokogiri::HTML(last_response.body)

      assert last_response.ok?
      assert_equal 2, html.css('.list-group-item').size
    end
  end
end
