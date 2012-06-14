require 'fb_burrito'

describe "Facebook Graph" do

  before(:each) do
    @options = {
      :auth_code => "AQARhsEpSwgXziIdX73_qdVCJ-mmIwXTLF0ckeT4kILb8nNx7jnQg37Ro4wlzdkfAHBoPkH5QSRmxBG9_ar1TagkjbNEA90XzZPriz04cUtvOtoA7S9V7vCWCJ6kyFFq0AyEGuvyeS6Up7XeH8azGU_UW-2VuLUk2dc697HIbpIuGA2HBRyHE3F1jHpMt3ry-iQ",
      :access_token => "AAAEW9np7y4gBAONfO9ffLoLJMTClzoJZBxAxLizzskstyhGbR4qz0jKu5sZCnRjuumiHHitM575zG4WMxijwqZA0WZARSf8ZAfwt5SFYrmwZDZD"
    }
  end

  it "should publish to a users feed" do
    options = {
      :access_token => @options[:access_token],
      :message => "My message",
      :name => "My name",
      :caption => "My caption",
      :description => "My description",
      :picture => "https://s3.amazonaws.com/uploads.hipchat.com/10651/44394/nrr1w7vrzfobny2/Critz_duuuuude.gif",
      :link => "https://github.com/ovenbits-ingredients/fb_burrito"
    }

    res = FbBurrito.publish_feed!(options)
    res.should include(:id)
  end

end
