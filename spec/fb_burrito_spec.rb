require 'fb_burrito'

describe "Facebook Graph" do

  it "should return a Facebook Authorization url" do
    url = FbBurrito.auth_url
    uri = URI.parse(url)

    query_params = uri.query.split("&")
    query_hash = query_params.inject({}) do |hash, param|
      k, v = param.split("=")
      hash[k.to_sym] = v
      hash
    end

    # host should be facebook
    uri.host.should eq("graph.facebook.com")

    # auth url should include the app_id from the config file
    query_hash.should include(:client_id)
    query_hash[:client_id].should eq(FbBurrito.config[:app_id].to_s)

    # auth url should include the redirewct_url from the config file
    query_hash.should include(:redirect_uri)
    query_hash[:redirect_uri].should eq(
      CGI.escape(FbBurrito.config[:redirect_url])
    )
  end

end