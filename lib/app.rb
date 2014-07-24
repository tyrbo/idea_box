require 'idea_box'
require 'rack-flash'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'
  set :session_secret, ENV['SESSION_SECRET'] ||= 'secret'

  use Rack::SslEnforcer, except_environments: ['development', 'test']
  use Rack::Flash

  enable :sessions

  before do
    @user = current_user
  end

  not_found do
    erb :error
  end

  get '/' do
    erb :index, locals: { ideas: IdeaStore.all.sort }
  end

  get '/:id/edit' do |id|
    protected!(id) do
      idea = IdeaStore.find(id.to_i)
      erb :edit, locals: { idea: idea }
    end
  end

  put '/:id' do |id|
    protected!(id) do
      idea = IdeaStore.find(id.to_i)
      IdeaStore.update(idea, params[:idea])
      redirect '/'
    end
  end

  post '/' do
    protected! do
      IdeaStore.create(params[:idea], current_user)
      redirect '/'
    end
  end

  post '/:id/like' do |id|
    protected! do
      idea = IdeaStore.find(id.to_i)
      idea.like!
      IdeaStore.update(idea, idea.to_h)
      redirect '/'
    end
  end

  post '/:id/dislike' do |id|
    protected! do
      idea = IdeaStore.find(id.to_i)
      idea.dislike!
      IdeaStore.update(idea, idea.to_h)
      redirect '/'
    end
  end

  post '/sms' do
    puts "Got params: #{params}."
    if user = UserStore.find_by_number(params[:From])
      title, description = params[:Body].split(',', 2)
      IdeaStore.create({ 'title' => title, 'description' => description.strip }, user)
    end
    ''
  end

  delete '/:id' do |id|
    protected!(id) do
      IdeaStore.delete(id.to_i)
      redirect '/'
    end
  end

  post '/users/new' do
    unless UserStore.exists?(params[:user][:username])
      flash[:success] = 'Account created. You may now log in.'
      user = User.new(params[:user])
      UserStore.create(user.to_h)
    else
      flash[:error] = 'That username has already been taken.'
    end
    redirect '/'
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    if user = UserStore.login(params[:user])
      session[:uid] = user.id
      redirect '/'
    else
      redirect '/'
    end
  end

  get '/logout' do
    flash[:info] = 'You have been logged out.'
    session[:uid] = nil
    redirect '/'
  end

  def current_user
    if session[:uid]
      UserStore.find(session['uid'])
    end
  end

  def protected!(id = nil)
    authorized = false

    if id && current_user
      idea = IdeaStore.find(id.to_i)
      authorized = true if idea.user_id == current_user.id
    else
      authorized = true if current_user
    end

    if authorized
      yield
    else
      flash[:error] = 'You must be logged in to access that resource.'
      redirect '/'
    end
  end
end
