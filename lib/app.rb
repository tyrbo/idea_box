require 'idea_box'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'

  use Rack::SslEnforcer, except_environments: ['development', 'test']

  enable :sessions

  not_found do
    erb :error
  end

  get '/' do
    erb :index, locals: { ideas: IdeaStore.all.sort, user: current_user }
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: { idea: idea }
  end

  put '/:id' do |id|
    idea = IdeaStore.find(id.to_i)
    IdeaStore.update(idea, params[:idea])
    redirect '/'
  end

  post '/' do
    IdeaStore.create(params[:idea])
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(idea, idea.to_h)
    redirect '/'
  end

  post '/:id/dislike' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.dislike!
    IdeaStore.update(idea, idea.to_h)
    redirect '/'
  end
  
  post '/sms' do
    title, description = params[:Body].split(',', 2)
    IdeaStore.create({ 'title' => title, 'description' => description.strip })
    ''
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  post '/users' do
    if user = UserStore.login(params[:user])
      session['uid'] = user.id
      redirect '/'
    else
      redirect '/', locals: { errors: 'Invalid username or password.' }
    end
  end

  post '/users/new' do
    user = User.new(params[:user])
    UserStore.create(user.to_h)
    redirect '/'
  end
  
  def current_user
    if session['uid']
      UserStore.find(session['uid'])
    end
  end
end
