require 'sinatra/base'
require 'thin'        # Do we need to require thin?
require 'json'
require 'redis'
require_relative 'deploy'
require_relative 'runner'

class App < Sinatra::Base

  post '/deploy/' do
    d = Deploy.new(params[:env], params[:tag], params[:name])
    
    d.runner = Runner.new
    d.redis = Redis.new(:host => "127.0.0.1", :port => 6379)

    d.run!
    redirect "/deploy/#{d.id}/"
  end  

  get '/deploy/:id/' do
    d = Deploy.get(params[:id]) or halt(404)
    erb :'deploy/view', :locals => {:deploy => deploy}
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

end