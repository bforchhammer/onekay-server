# config.ru
require_relative './config/environment'
use Rack::MethodOverride
use MessagesController
run ApplicationController
