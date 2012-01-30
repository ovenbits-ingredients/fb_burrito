# A wrapper for the fb_graph gem

A wrapper for commonly used Facebook Graph API calls.

## Config

The fb_fgraph gem is required.

See config/facebook.yml for configuration options.

## Usage

Returns a Facebook authorization URL that will redirect back to the redirect_url given in the config file.

    Facebook.auth_url

Returns an access token from the code returned in the Facebook.auth_url redirect.

    Facebook.get_access_token(auth_code)

Returns a list of friends for the given access_token.

    Facebook.friends(access_token)

Publishes content to the given user's wall.

    Facebook.publish!(
      :access_token => access_token, # from user
      :friend_fb_id => fb_id, # target user
      :message => your-post-message,
      :name => your-post-title,
      :description => your-post-description,
      :picture => your-picture-url,
      :link => your-website-url
    )