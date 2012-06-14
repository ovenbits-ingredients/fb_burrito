require 'fb_burrito'

describe "Facebook Graph" do

  before(:each) do
    @options = {
      :auth_code => "AQARhsEpSwgXziIdX73_qdVCJ-mmIwXTLF0ckeT4kILb8nNx7jnQg37Ro4wlzdkfAHBoPkH5QSRmxBG9_ar1TagkjbNEA90XzZPriz04cUtvOtoA7S9V7vCWCJ6kyFFq0AyEGuvyeS6Up7XeH8azGU_UW-2VuLUk2dc697HIbpIuGA2HBRyHE3F1jHpMt3ry-iQ",
      :access_token => "AAAEW9np7y4gBAONfO9ffLoLJMTClzoJZBxAxLizzskstyhGbR4qz0jKu5sZCnRjuumiHHitM575zG4WMxijwqZA0WZARSf8ZAfwt5SFYrmwZDZD"
    }
  end

  it "should query a user's friends" do
    friends = FbBurrito::FQL.new(
      :access_token => @options[:access_token],
      :q => "select uid2 from friend where uid1 = 805120116"
    )

    data = friends.data

    data.should_not eq(nil)

    data.first.should include(:uid2)
  end

end