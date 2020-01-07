# module Codebreaker_web
#   class Menu
#     def self.call(env)
#       new(env).response.finish
#     end

#     def initialize(env)
#       @request = Rack::Request.new(env)
#     end

#     def response
#       case @request.path
#       when '/'
#         Rack::Response.new(load_file('menu.html.erb'))
#       end
#     end
#   end
# end