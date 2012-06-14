require 'fb_burrito'

describe "Facebook Graph" do

  before(:each) do
    @options = {
      :auth_code => "AQARhsEpSwgXziIdX73_qdVCJ-mmIwXTLF0ckeT4kILb8nNx7jnQg37Ro4wlzdkfAHBoPkH5QSRmxBG9_ar1TagkjbNEA90XzZPriz04cUtvOtoA7S9V7vCWCJ6kyFFq0AyEGuvyeS6Up7XeH8azGU_UW-2VuLUk2dc697HIbpIuGA2HBRyHE3F1jHpMt3ry-iQ",
      :access_token => "AAAEW9np7y4gBAONfO9ffLoLJMTClzoJZBxAxLizzskstyhGbR4qz0jKu5sZCnRjuumiHHitM575zG4WMxijwqZA0WZARSf8ZAfwt5SFYrmwZDZD"
    }
  end

  it "should return a valid Facebook authorization url" do
    uri = URI.parse(FbBurrito.auth_url)

    uri.query.should =~ /client_id/
    uri.query.should =~ /scope/
    uri.query.should =~ /redirect_uri/
  end

  it "should accept a permissions parameter" do
    uri = URI.parse(FbBurrito.auth_url(:permissions => "manage_pages"))

    uri.query.should =~ /manage_pages/
  end

  it "should return a Facebook access_token" do
    token = FbBurrito.get_access_token(:auth_code => @options[:auth_code])

    token.should_not eq(nil)
  end

  it "should raise an exception with missing params" do
    lambda { FbBurrito.get_access_token }.should raise_error
  end

  it "should raise an exception with an invalid auth_code" do
    lambda { FbBurrito.get_access_token(:auth_code => "asdf") }.should raise_error
  end

end