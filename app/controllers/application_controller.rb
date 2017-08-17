class ApplicationController < Sinatra::Base
  configure :development do
    # Reload sinatra server on code changes during development
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  configure :production, :development do
    enable :logging
  end

  configure do
    set :firebase_key, ENV['FIREBASE_KEY']
  end

end
