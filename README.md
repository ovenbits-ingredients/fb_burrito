# FbBurrito

A convenience wrapper for commonly used Facebook Graph API calls.

## Config

The httparty gem is required.

See config/facebook.yml for configuration options.

## Usage

Returns a Facebook authorization URL that will redirect back to the redirect_url in the config file or the given parameter.

    FbBurrito.auth_url
    FbBurrito.auth_url(:redirect_url => "http://some_url")

Finds or creates a user from an auth_code returned by the Auth.url using the user_attributes defined in the config file. Returns an FbGraph User object.

    FbBurrito.find_or_create_user!(:auth_code => code)

Returns a user for the given param.

    FbBurrito.user(:auth_code => code)
    FbBurrito.user(:access_token => token)
    FbBurrito.user(:uid => uid)

Publish to a user's feed for the given access_token.

    FbBurrito.publish_feed!(
      :access_token => token,
      :message => "My message",
      :name => "My name",
      :caption => "My caption",
      :description => "My description"
    )
