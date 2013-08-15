require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/json'
require 'multi_json'
require 'thin'                # Do we need to require thin?
require 'redis'
require 'active_support/core_ext/string'

require_relative 'deploy'
require_relative 'runner'
require_relative 'keeper'

class Drake < Sinatra::Base
  helpers Sinatra::ContentFor
  helpers Sinatra::JSON

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

  get '/deploy/list/' do
    all = Deploy.get_all
    erb :'deploy/list', :locals => {:deploys => all}
  end

  get '/deploy/:id/' do
    d = Deploy.get(params[:id]) or halt(404)
    erb :'deploy/view', :locals => {:deploy => d}
  end

  get '/deploy/:id/poll/' do
    d = Deploy.get(params[:id]) or halt(404)

    json(
      :id => d.id,
      :log => h(d.log.read)
    )
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