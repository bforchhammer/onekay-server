# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) {|repo_name| "https://github.com/#{repo_name}"}

ruby '2.4.0'

gem 'activemodel'
gem 'dotenv', groups: [:development, :test]
gem 'pry'
gem 'puma', groups: [:production]
gem 'rack-timeout'
gem 'rake'
gem 'require_all' # Helps to load dependencies
gem 'sinatra'
gem 'sinatra-contrib'

group :development do
  gem 'sinatra-reloader'
  gem 'byebug'
end
