module RakeWeb
  class CodebreakerWeb
    def self.call(env)
      new(env).response.finish
    end
    @@game = CodebreakerAp::Game.new
    def initialize(env)
      @request = Rack::Request.new(env)
    end

    def response
      case @request.path
      when '/' then Rack::Response.new(render('menu.html.erb'))
      when '/set_game_instance' then set_game_instance
      when '/rules' then Rack::Response.new(render('rules.html.erb'))
      when '/game' then Rack::Response.new(render('game.html.erb'))
      when '/hint' then hint
      when '/submit_answer' then submit_answer
      when '/statistics' then Rack::Response.new(render('statistics.html.erb'))
      when '/save_stats' then save_statistic
      when '/win' then Rack::Response.new(render('win.html.erb'))
      when '/lose' then Rack::Response.new(render('lose.html.erb'))
      else Rack::Response.new('Not Found', 404)
      end
    end

    def save_statistic
      @@game.save_stats(@request.cookies['player_name'], @@game.difficulty)
      Rack::Response.new do |response|
        response.redirect('/win')
      end
    end

    def apply_game_level
      if(@request.params['level'])
        return @request.params['level']
      elsif @request.cookies['level']
        return @request.cookies['level']
      end
    end

    def set_game_instance
      Rack::Response.new do |response|
        set_player_cookies(response)
        level = apply_game_level
        @@game = CodebreakerAp::Game.new
        @@game.difficulty.initialize_difficulty(level)
        set_game_cookies(response)
        response.redirect('/game')
      end
    end

    def set_player_cookies(response)
      return unless @request.params['player_name'] && @request.params['level']

      response.set_cookie('player_name', @request.params['player_name'])
      response.set_cookie('level', @request.params['level'])
    end

    def set_game_cookies(response)
      response.set_cookie('game_lvl', @@game.difficulty.level)
      response.set_cookie('secret_code', @@game.secret_code.join)
      response.set_cookie('hint', nil)
      response.set_cookie('checked_answer', nil)
    end

    def hint
      Rack::Response.new do |response|
        game_hint = @@game.take_hint
        if @request.cookies['hint'] && (game_hint.is_a? Integer)
          response.set_cookie('hint', @request.cookies['hint'] + game_hint.to_s)
        elsif game_hint.is_a? Integer
          response.set_cookie('hint', game_hint)
        end
        response.redirect('/game')
      end
    end

    def submit_answer
      Rack::Response.new do |response|
        if @request.params['number']
          checked_answer = @@game.check_answer(@request.params['number'])
          response.set_cookie('checked_answer', checked_answer)
        end
        if @@game.win? then response.redirect('/win')
        elsif @@game.difficulty.attempts.zero? then response.redirect('/lose')
        else response.redirect('/game')
        end
      end
    end

    def render(template)
      path = File.expand_path("views/#{template}", __dir__)
      ERB.new(File.read(path)).result(binding)
    end
  end
end
