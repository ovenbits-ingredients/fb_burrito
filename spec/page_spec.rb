require 'fb_burrito'

describe "Facebook Pages" do

  before(:each) do
    @options = {
      :auth_code => "AQARhsEpSwgXziIdX73_qdVCJ-mmIwXTLF0ckeT4kILb8nNx7jnQg37Ro4wlzdkfAHBoPkH5QSRmxBG9_ar1TagkjbNEA90XzZPriz04cUtvOtoA7S9V7vCWCJ6kyFFq0AyEGuvyeS6Up7XeH8azGU_UW-2VuLUk2dc697HIbpIuGA2HBRyHE3F1jHpMt3ry-iQ",
      :access_token => "AAAEW9np7y4gBAONfO9ffLoLJMTClzoJZBxAxLizzskstyhGbR4qz0jKu5sZCnRjuumiHHitM575zG4WMxijwqZA0WZARSf8ZAfwt5SFYrmwZDZD"
    }
  end

  it "should fetch a Page" do
    page = FbBurrito::Page.new(
      :access_token => @options[:access_token],
      :id => "104670449570510"
    )

    data = page.data
    data.should include(:name)
    data.should include(:category)
    data.should include(:link)
  end

  it "should fetch a Page post" do
    post = FbBurrito::Post.new(
      :access_token => @options[:access_token],
      :id => "104670449570510_395202063850679"
    )

    data = post.data
    data.should include(:from)
    data.should include(:comments)
  end

end