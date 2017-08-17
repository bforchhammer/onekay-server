require 'bundler'
Bundler.require

require 'dotenv/load' if development?

# Call as early as possible so rack-timeout runs before all other middleware.
require 'rack-timeout'
use Rack::Timeout, service_timeout: 5

require_all 'app'
