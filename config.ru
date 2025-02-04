require 'rack'
require 'erb'
require 'codebreaker_ap'
require_relative 'lib/codebreaker_web.rb'

app = Rack::Builder.new do
  use Rack::Reloader
  use Rack::Static, urls: ['/assets']
  run RakeWeb::CodebreakerWeb
end

run app
