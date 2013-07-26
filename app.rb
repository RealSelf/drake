require 'sinatra/base'
require 'thin'        # Do we need to require thin?
require 'json'
require 'redis'
require_relative 'deploy'
require_relative 'runner'
require_relative 'keeper'

class App < Sinatra::Base
  Keeper.redis = Redis.new(:host => "127.0.0.1", :port => 6379)
  Deploy.runner = Runner.new
  Deploy.keeper = Keeper.new(:deploy)

  get '/' do
    erb :index
  end

  post '/deploy/' do
    d = Deploy.new(params[:env], params[:tag], params[:name])
    d.run

    redirect "/deploy/#{d.id}/"
  end  

  get '/deploy/:id/' do
    d = Deploy.get(params[:id]) or halt(404)
    
    erb :'deploy/view', :locals => {:deploy => d}
  end

  get '/deploy/:id/poll/' do
    d = Deploy.get(params[:id]) or halt(404)

    {
      :id => d.id,
      :status => d.status,
      :log => d.log
    }.to_json
  end

  get '/deploy/list/' do
    all = Deploy.get(:all)

    erb :'deploy/list', :locals => {:deploys => all}
  end

  helpers do
    def h(text)
      Rack::Utils.escape_html(text)
    end
  end
end

App.run!({:port => 3000})