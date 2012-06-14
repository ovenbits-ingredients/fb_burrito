require 'fb_burrito'

describe "Facebook Graph" do

  before(:each) do
    @options = {
      :auth_code => "AQARhsEpSwgXziIdX73_qdVCJ-mmIwXTLF0ckeT4kILb8nNx7jnQg37Ro4wlzdkfAHBoPkH5QSRmxBG9_ar1TagkjbNEA90XzZPriz04cUtvOtoA7S9V7vCWCJ6kyFFq0AyEGuvyeS6Up7XeH8azGU_UW-2VuLUk2dc697HIbpIuGA2HBRyHE3F1jHpMt3ry-iQ",
      :access_token => "AAAEW9np7y4gBAONfO9ffLoLJMTClzoJZBxAxLizzskstyhGbR4qz0jKu5sZCnRjuumiHHitM575zG4WMxijwqZA0WZARSf8ZAfwt5SFYrmwZDZD"
    }
  end

  it "should raise an exception with missing params" do
    lambda { FbBurrito.user }.should raise_error
  end

  it "should raise an exception with an invalid auth_code" do
    lambda { FbBurrito.user(:auth_code => "asdf") }.should raise_error
  end

  it "should raise an exception with an invalid access_token" do
    lambda { FbBurrito.user(:access_token => "asdf") }.should raise_error
  end

  it "should raise an exception with an invalid access_token" do
    lambda { FbBurrito.user(:uid => "0") }.should raise_error
  end

  it "should return a Facebook user's non-public info from an auth_code" do
    user = FbBurrito.user(:auth_code => @options[:auth_code])

    user.should include(:id)
    user.should include(:verified)
  end

  it "should return a Facebook user's non-public info from an access_token" do
    user = FbBurrito.user(:access_token => @options[:access_token])

    user.should include(:id)
    user.should include(:verified)
  end

  it "should return a Facebook user's public info from a uid" do
    user = FbBurrito.user(:uid => "805120116")

    user.should include(:id)
    user.should_not include(:verified)
  end

  it "should create a new user from a uid" do
    user = FbBurrito.find_or_create_user!(:uid => "805120116")

    user.first_name.should_not eq(nil)
    user.last_name.should_not eq(nil)
    user.fb_uid.should_not eq(nil)
    user.password.should_not eq(nil)

    user.email.should eq(nil)
    user.fb_token.should eq(nil)
    user.is_ghost.should eq(true)
  end

  it "should create a new user from an auth_code" do
    user = FbBurrito.find_or_create_user!(:auth_code => @options[:auth_code])

    user.first_name.should_not eq(nil)
    user.last_name.should_not eq(nil)
    user.fb_uid.should_not eq(nil)
    user.password.should_not eq(nil)

    user.email.should_not eq(nil)
    user.fb_token.should_not eq(nil)
    user.is_ghost.should eq(nil)
  end

  it "should find an existing user from a uid" do
    user = FbBurrito.find_or_create_user!(:uid => "639106065")

    user.first_name.should_not eq(nil)
    user.last_name.should_not eq(nil)
    user.fb_uid.should_not eq(nil)
    user.password.should_not eq(nil)

    user.email.should_not eq(nil)
    user.fb_token.should eq(nil)
    user.is_ghost.should eq(nil)
  end

end

# used to simulate an active record User model so we can test creating a user
class User
  attr_accessor :first_name, :last_name, :username, :email, :password, :fb_token, :fb_uid, :is_ghost

  def self.where(*args)
    if args[1] == "639106065"
      [new(
        :first_name => "Boosh",
        :last_name => "Dude",
        :username => "booshdude",
        :email => "dude@dude.com",
        :fb_uid => "639106065",
        :fb_token => "asdf",
        :password => "dude"
      )]
    else
      []
    end
  end

  def initialize(*args)
    args.first.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def save!
    self
  end

  def fb_uid?
    !fb_uid.nil?
  end

  def fb_token?
    !fb_token.nil?
  end

  def is_ghost?
    email.nil?
  end

end
