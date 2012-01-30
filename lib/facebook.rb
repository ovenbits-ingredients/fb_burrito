class Facebook

  require 'fb_graph'

  class << self

    ## properties

    def config
      path = File.join(Rails.root, 'config', 'facebook.yml')
      yaml = YAML.load_file(path)

      yaml[Rails.env.to_sym]
    end

    def permissions
      config[:permissions]
    end

    def auth(redirect_url=nil)
      FbGraph::Auth.new(
        config[:app_id],
        config[:app_secret],
        :redirect_uri => (redirect_url || config[:redirect_url])
      )
    end

    def user(access_token, friend_fb_id=nil)
      FbGraph::User.fetch(
        (friend_fb_id || "me"),
        :access_token => access_token
      )
    end


    ## methods

    def auth_url(redirect_url=nil)
      auth(redirect_url).client.authorization_uri(
        :scope => config[:permissions].join(",")
      )
    end

    def get_access_token(code)
      client = auth.client
      client.authorization_code = code
      client.access_token!.to_s
    end

    def friends(access_token)
      user(access_token).friends
    end

    def publish!(options)
      user(options[:access_token], options[:friend_fb_id]).feed!(
        :message => options[:message],
        :name => options[:name],
        :description => options[:description],
        :picture => options[:picture],
        :link => options[:link]
      )
    end

  end

end
