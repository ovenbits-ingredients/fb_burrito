# A wrapper for the fb_graph gem

A convenience wrapper for commonly used Facebook Graph API calls.

## Config

The fb_fgraph gem is required.
The httparty gem is required.

See config/facebook.yml for configuration options.

## Usage

Returns a Facebook authorization URL that will redirect back to the redirect_url in the config file or the given parameter.

    FbBurrito.auth_url
    FbBurrito.auth_url("http://some_url")

Finds or creates a user from an auth_code returned by the Auth.url using the user_attributes defined in the config file. Returns an FbGraph User object.

  FbBurrito.find_or_create_user!(:auth_code => code)

Returns a user for the given param.

    FbBurrito.user(:access_token => token)
    FbBurrito.user(:uid => uid)

Returns a list of friends for the given param.

    FbBurrito.friends(:access_token => token)

    user = FbBurrito.find_or_create_user!(:auth_code => code)
    user.friends


Publishes content to the given user's wall.

    FbBurrito.publish!(
      :access_token => access_token, # from user
      :friend_uid => uid, # target user
      :message => your-message,
      :name => your-title,
      :description => your-description,
      :picture => your-picture-url,
      :link => your-website-url
    )