require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if logged_in?
      redirect '/tweets'
    else
      erb :'users/create_user'
    end
  end

  post '/signup' do
    @user = User.create(params)
    session[:user_id] = @user.id
    if params[:username].empty? || params[:email].empty? || params[:password].empty?
    	redirect '/signup'
    else
    	redirect '/tweets'
    end
  end

  get '/login' do
    if logged_in?
      redirect '/tweets'
    else
      erb :'users/login'
    end
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect '/tweets'
    else
      redirect '/login'
    end
  end

  get '/logout' do
    if logged_in?
      session.clear
    end
    redirect '/login'
  end

  get '/tweets' do
    @user = User.find_by(id: session[:user_id])
    if logged_in?
      erb :'tweets/tweets'
    else
      redirect '/login'
    end
  end

  get '/tweets/new' do
    if logged_in?
      @user = User.find_by(id: session[:user_id])
      erb :'tweets/create_tweet'
    else
      redirect '/login'
    end
  end

  get '/tweets/:tweet_id' do
    @tweet = Tweet.find_by(id: params[:tweet_id])
    @user = User.find_by(id: @tweet.user_id)
    if logged_in?
      erb :'tweets/show_tweet'
    else
      redirect '/login'
    end
  end

  get '/tweets/:tweet_id/edit' do
    if logged_in?
      @tweet = Tweet.find_by(id: params[:tweet_id])
      erb :'tweets/edit_tweet'
    else
      redirect '/login'
    end
  end

  patch '/tweets/:tweet_id' do
    @tweet = Tweet.find_by(id: params[:tweet_id])
    if !params[:content].empty?
      @tweet.update(content: params[:content])
    else
      redirect "/tweets/#{@tweet.id}/edit"
    end

  end

  post '/tweets' do
    @user = User.find_by(id: session[:user_id])
    if !params[:content].empty?
      @tweet = Tweet.create(content: params[:content], user_id: @user.id)
      redirect '/tweets'
    else
      redirect '/tweets/new'
    end
  end

  get '/users/:user_slug' do
    @user = User.find_by_slug(params[:user_slug])
    erb :'users/show'
  end

  delete '/tweets/:tweet_id' do
    @tweet = Tweet.find_by(id: params[:tweet_id])
    if session[:user_id] == @tweet.user_id
      @tweet.delete
    end
    redirect '/tweets'
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end
end
