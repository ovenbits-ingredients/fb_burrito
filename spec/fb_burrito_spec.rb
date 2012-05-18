require 'fb_burrito'

describe "Facebook Graph" do

  it "should return a valid Facebook authorization url" do
    uri = URI.parse(FbBurrito.auth_url)

    log("Auth url", uri)

    uri.query.should =~ /client_id/
    uri.query.should =~ /scope/
    uri.query.should =~ /redirect_uri/
  end

  it "should return a Facebook access_token" do
    token = FbBurrito.get_access_token(:auth_code => "AQBli9JgrXT0JhDDXw6x0E9V2w_mvxSQHEgkBYS5-jdxdZrd0mhGs59KIr95tAnS-OMX2GjXuLxBcaCqf708gx7z1Ne4RoDXT3P7aB057AgUt9f1v3SVdLENPGntFR9QuujhBaPrDQu7R0oE-Yj4OcZZ_yTKGHhmiKyPumYUvsZlv65Zs4gkqhLrV2WgB3W1QbA")

    log("Access token", token)

    token.should_not eq(nil)
  end

  it "should raise an exception with missing params" do
    lambda { FbBurrito.get_access_token }.should raise_error
  end

  it "should raise an exception with an invalid auth_code" do
    lambda { FbBurrito.get_access_token(:auth_code => "asdf") }.should raise_error
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
    user = FbBurrito.user(:auth_code => "AQBli9JgrXT0JhDDXw6x0E9V2w_mvxSQHEgkBYS5-jdxdZrd0mhGs59KIr95tAnS-OMX2GjXuLxBcaCqf708gx7z1Ne4RoDXT3P7aB057AgUt9f1v3SVdLENPGntFR9QuujhBaPrDQu7R0oE-Yj4OcZZ_yTKGHhmiKyPumYUvsZlv65Zs4gkqhLrV2WgB3W1QbA")

    log("User", user)

    user.should include(:id)
    user.should include(:verified)
  end

  it "should return a Facebook user's non-public info from an access_token" do
    user = FbBurrito.user(:access_token => "AAAEW9np7y4gBAFzwdDxGwfSHw5umhbBT8vmdZBOvgSAVoAekh7nHz5nYiMQJAIFRNHLTkGBhDdZAZAPrZBTjfxGvWbO64AGLCzajrDS9BAZDZD")

    log("User", user)

    user.should include(:id)
    user.should include(:verified)
  end

  it "should return a Facebook user's public info from a uid" do
    user = FbBurrito.user(:uid => "805120116")

    log("User", user)

    user.should include(:id)
    user.should_not include(:verified)
  end

  it "should create a new user from a uid" do
    user = FbBurrito.find_or_create_user!(:uid => "805120116")

    log("User", user)

    user.first_name.should_not eq(nil)
    user.last_name.should_not eq(nil)
    user.fb_uid.should_not eq(nil)
    user.password.should_not eq(nil)

    user.email.should eq(nil)
    user.fb_token.should eq(nil)
  end

  it "should create a new user from an auth_code" do
    user = FbBurrito.find_or_create_user!(:auth_code => "AQBli9JgrXT0JhDDXw6x0E9V2w_mvxSQHEgkBYS5-jdxdZrd0mhGs59KIr95tAnS-OMX2GjXuLxBcaCqf708gx7z1Ne4RoDXT3P7aB057AgUt9f1v3SVdLENPGntFR9QuujhBaPrDQu7R0oE-Yj4OcZZ_yTKGHhmiKyPumYUvsZlv65Zs4gkqhLrV2WgB3W1QbA")

    log("User", user)

    user.first_name.should_not eq(nil)
    user.last_name.should_not eq(nil)
    user.fb_uid.should_not eq(nil)
    user.password.should_not eq(nil)

    user.email.should_not eq(nil)
    user.fb_token.should_not eq(nil)
  end

  it "should find an existing user from a uid" do
    user = FbBurrito.find_or_create_user!(:uid => "639106065")

    log("User", user)

    user.first_name.should_not eq(nil)
    user.last_name.should_not eq(nil)
    user.fb_uid.should_not eq(nil)
    user.password.should_not eq(nil)

    user.email.should_not eq(nil)
    user.fb_token.should eq(nil)
  end

end

def log(name, data)
  # puts "\n=== #{name} ===\n#{data.inspect}\n======"
end

# used to simulate an active record User model so we can test creating a user
class User
  attr_accessor :first_name, :last_name, :email, :password, :fb_token, :fb_uid

  def self.where(*args)
    if args[1] == "639106065"
      [new(
        :first_name => "Boosh",
        :last_name => "Dude",
        :email => "boosh.dude@gmail.com",
        :fb_uid => nil,
        :fb_token => nil,
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
    true
  end

  def fb_token?
    true
  end

end
