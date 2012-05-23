class FbBurrito

  require 'cgi'
  require 'json'
  require 'httparty'

  def self.config
    path = File.join('config', 'facebook.yml')
    yaml = YAML.load_file(path)

    return yaml[:environment]
  end

  def self.auth_url(options={})
    OpenGraph.new(options).auth_url
  end

  def self.get_access_token(options={})
    OpenGraph.new(options).get_access_token
  end

  def self.user(options={})
    OpenGraph.new(options).user
  end

  def self.find_or_create_user!(options)
    OpenGraph.new(options).find_or_create!
  end

  def self.publish_feed!(options)
    OpenGraph.new(options).publish_feed!
  end

  class FbUser

    def friends
      #TODO: remove FbGraph dependency

      # fetch.friends
    end

    def page(page_id)
      #TODO: remove FbGraph dependency

      # FbGraph::Page.new(page_id).fetch(
      #   :access_token => access_token,
      #   :fields => [:access_token, :name]
      # )
    end

    def exchange_token
      #TODO: remove FbGraph dependency

      # auth = FbGraph::Auth.new(
      #   FbBurrito.config[:app_id],
      #   FbBurrito.config[:app_secret]
      # )
      # res = auth.exchange_token!(access_token)
      # res.access_token
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

      return Util.parse_response(res)
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

  class OpenGraph
    include HTTParty

    attr_accessor :config, :options, :auth_code, :access_token, :uid

    def initialize(options={})
      self.config = FbBurrito.config
      self.auth_code = options.delete(:auth_code)
      self.access_token = options.delete(:access_token)
      self.uid = options.delete(:uid) || "me"

      redirect_url = options.delete(:redirect_url) || config[:redirect_url]
      scope = if (perms = options.delete(:permissions))
        perms.is_a?(Array) ? perms.join(",") : perms
      else
        config[:permissions].join(",")
      end

      self.options = options.merge(
        :client_id => config[:app_id],
        :redirect_uri => CGI.escape(redirect_url),
        :scope => scope
      )
    end

    def auth_url
      uri = URI.parse("https://www.facebook.com/dialog/oauth")
      uri.query = Util.to_query(options)

      return uri.to_s
    end

    def get_access_token
      uri = URI.parse("https://graph.facebook.com/oauth/access_token")

      query_hash = options.merge(
        :client_secret => config[:app_secret],
        :code => auth_code
      )

      uri.query = Util.to_query(query_hash)

      res = OpenGraph.get(uri.to_s)
      data = Util.parse_response(res)

      token = data[:access_token]
      self.access_token = token

      return token
    end

    def user
      get_access_token if auth_code

      uri = URI.parse("https://graph.facebook.com/#{uid}")
      uri.query = "access_token=#{access_token}" if access_token

      res = OpenGraph.get(uri.to_s)

      return Util.parse_response(res)
    end

    def find_or_create!
      # must have fb_user info to continue
      return nil unless (fb_user = user)

      # default class is User
      user_attr = FbBurrito.config[:user_attributes]
      user_class = Object.class_eval(
        FbBurrito.config[:user_attributes][:user_class] ||
        "User"
      )

      puts "Finding user..."
      # check to see if the user already exists
      if @user = user_class.where(
        "#{user_attr[:id].to_s} = ? OR #{user_attr[:email].to_s} = ?",
        fb_user[:id],
        fb_user[:email]
      ).first
        puts " Updating user..."
        # check for a ghost user
        if user_attr[:is_ghost] && (email = fb_user[:email])
          set_user_attr(:email, email)
          set_user_attr(:is_ghost, false)
        end
        set_user_attr(:uid, fb_user[:id])
        set_user_attr(:access_token, access_token)

      # if the user does not exist, create it
      else
        puts " Creating user..."

        @user = user_class.new(
          user_attr[:first_name] => fb_user[:first_name],
          user_attr[:last_name] => fb_user[:last_name],
          user_attr[:email] => fb_user[:email],
          user_attr[:uid] => fb_user[:id],
          user_attr[:access_token] => access_token,
          user_attr[:password] => (options[:password] || Util.friendly_token)
        )

        # check for a ghost user
        if user_attr[:is_ghost] && fb_user[:email].nil?
          set_user_attr(:is_ghost, true)
        end
      end
      @user.save!

      return @user
    end

    def publish_feed!
      uri = URI.parse("https://graph.facebook.com/#{uid}/feed")
      uri.query = "access_token=#{access_token}"

      res = OpenGraph.post(uri.to_s, :body => options)

      return Util.parse_response(res)
    end

    private

    def set_user_attr(key, value)
      user_attr = config[:user_attributes]

      return unless (@user.send("#{user_attr[key]}?") rescue nil)

      @user.send("#{user_attr[key]}=", value)
    end

  end

  class Util

    class << self

      def friendly_token
        token = ""

        friendly_chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
        1.upto(20) { |i| token << friendly_chars[rand(friendly_chars.size-1)] }

        return token
      end

      # convert a hash to a querystring params string
      def to_query(hash)
        hash.inject([]) do |params, (k, v)|
          params << "#{k}=#{v}"
          params
        end.join("&")
      end

      def from_query(str)
        params = str.split("&")
        params.inject({}) do |new_hash, param|
          k, v = param.split("=")
          new_hash[k.to_sym] = v
          new_hash
        end
      end

      # recursively convert hash string keys to symbols
      def keys_to_symbols(hash)
        hash.inject({}) do |new_hash, (k, v)|
          new_hash[k.to_sym] = if v.is_a?(Hash)
            keys_to_symbols(v)
          elsif v.is_a?(Array)
            v.map{ |v| keys_to_symbols(v) }
          else
            v
          end

          new_hash
        end
      end

      def parse_response(res)
        body = res.body

        data = if is_json?(body)
          json = JSON.parse(body)
          keys_to_symbols(json)
        else
          from_query(body)
        end

        raise_error(data) if res.code > 200

        return data
      end

      def raise_error(data)
        error = data[:error]
        raise "#{error[:type]}: #{error[:code]}: #{error[:message]}"
      end

      def is_json?(str)
        begin
          JSON.parse(str).nil?
          true
        rescue
          false
        end
      end

    end # end self class

  end

end