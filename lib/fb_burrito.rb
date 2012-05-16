class FbBurrito

  require 'httparty'
  require 'fb_graph'

  def self.config
    path = File.join('config', 'facebook.yml')
    yaml = YAML.load_file(path)

    return yaml[:environment]
  end

  def self.auth_url(redirect_url=nil, options={})
    options.merge!(:redirect_url => redirect_url)
    Auth.new(options).url
  end

  def self.user(options)
  end

  def self.publish!(options)
    User.new(options).publish!
  end

  def self.friends(options)
    User.new(options).friends
  end

  def self.find_or_create_user!(options)
    User.new(options).find_or_create!
  end

  class User

    attr_accessor :auth_code, :access_token, :uid, :options

    def initialize(options={})
      if options.any?
        self.auth_code = options[:auth_code]
        self.access_token = options[:access_token] ||
                            Auth.new(options).get_access_token
        self.uid = options[:uid]
        self.options = options.reverse_merge(
          :user_class => FbBurrito.config[:user_attributes][:user_class],
          :password => friendly_token
        )
      end
    end


    ## methods

    def fetch
      puts "Fetching user..."

      return nil if uid.nil? && access_token.nil?

      FbGraph::User.fetch(uid || "me", :access_token => access_token)
    end

    def find_or_create!
      # must have fb_user info to continue
      return nil unless (fb_user = fetch)

      # default class is User
      user_attr = FbBurrito.config[:user_attributes]
      user_class = Object.class_eval(
        FbBurrito.config[:user_attributes][:class_user] ||
        "User"
      )

      puts "Finding user..."
      # check to see if the user already exists
      if user = user_class.where(
        "#{user_attr[:fb_id].to_s} = ? OR #{user_attr[:email].to_s} = ?",
        fb_user.identifier,
        fb_user.email
      ).first
        puts " Updating user..."
        # check for a ghost user
        if user_attr[:is_ghost] && user.send("#{user_attr[:is_ghost]}?") && (email = fb_user.email)
          user.send("#{user_attr[:email]}=", email)
          user.is_ghost = false
        end
        user.send("#{user_attr[:fb_id]}=", fb_user.identifier)
        user.send("#{user_attr[:fb_access_token]}=", access_token) if defined?(access_token)
      # if the user does not exist, create it
      else
        puts " Creating user..."
        first_name, last_name = if (name = fb_user.name)
          names = name.split(" ")
          [names.shift, names.join(" ")]
        else
          [fb_user.first_name, fb_user.last_name]
        end

        user = user_class.new(
          user_attr[:first_name] => first_name,
          user_attr[:last_name] => last_name,
          user_attr[:email] => fb_user.email || "",
          user_attr[:fb_id] => fb_user.identifier,
          user_attr[:password] => options[:password]
        )

        # set access_token
        user.send("#{user_attr[:fb_access_token]}=", access_token)

        # check for a ghost user
        if user_attr[:is_ghost] && fb_user.email.nil?
          user.send("#{user_attr[:is_ghost]}=", true)
        end
      end
      user.save!

      return user
    end

    def friends
      fetch.friends
    end

    def page(page_id)
      FbGraph::Page.new(page_id).fetch(
        :access_token => access_token,
        :fields => [:access_token, :name]
      )
    end

    def exchange_token
      auth = FbGraph::Auth.new(
        FbBurrito.config[:app_id],
        FbBurrito.config[:app_secret]
      )
      res = auth.exchange_token!(access_token)
      res.access_token
    end

    def publish!(options)
      fetch.feed!(
        :message => options[:message],
        :name => options[:name],
        :description => options[:description],
        :picture => options[:picture],
        :link => options[:link]
      )
    end

    def friendly_token
      token = ""

      friendly_chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      1.upto(20) { |i| token << friendly_chars[rand(friendly_chars.size-1)] }

      return token
    end

  end


  class Auth

    attr_accessor :redirect_url, :auth_code, :options

    def initialize(options={})
      self.redirect_url = options.delete(:redirect_url) ||
                          FbBurrito.config[:redirect_url]
      self.auth_code = options.delete(:auth_code)

      permissions = FbBurrito.config[:permissions] + options[:permissions].to_a
      self.options = options.merge(:scope => permissions.join(","))
    end

    def url
      client.authorization_uri(:scope => options[:scope])
    end

    def client
      FbGraph::Auth.new(
        FbBurrito.config[:app_id],
        FbBurrito.config[:app_secret],
        :redirect_uri => redirect_url
      ).client
    end

    def get_access_token
      return nil unless auth_code

      auth_client = client
      auth_client.authorization_code = auth_code

      res = auth_client.access_token!(:client_auth_body)
      res.access_token
    end
  end

  class FQL

    include HTTParty
    base_uri 'https://graph.facebook.com'

    def self.query(access_token, q)
      options = {
        :access_token => access_token,
        :q => q
      }
      res = get("/fql", :query => options)

      data = res.body
      JSON.parse(data)["data"]
    end

  end

  class Batch

    include HTTParty
    base_uri 'https://graph.facebook.com'

    def self.send(access_token, paths)
      batch_options = paths.inject([]) do |batch, path|
        batch.push({
          :method => "GET",
          :relative_url => path
        })
        batch
      end

      options = {
        :access_token => access_token,
        :batch => batch_options.to_json
      }

      res = post("/", :query => options)
      data = JSON.parse(res.body)

      if res.code == 200
        data.map do |obj|
          data = JSON.parse(obj["body"])
        end
      else
        error = data["error"]
        puts "#{error["type"]}: #{error["message"]}"
      end
    end

  end

end


# used to simulate an active record User model so we can test creating a user
class User
  attr_accessor :first_name, :last_name, :email, :password, :fb_token, :fb_uid

  def self.where(*args)
    []
  end

  def initialize(*args)
    args.first.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def save!
    self
  end
end
