Gem::Specification.new do |s|
  s.name        = 'fb_burrito'
  s.version     = '0.1.0'
  s.add_runtime_dependency "fb_graph", [">= 2.4.15"]
  s.add_runtime_dependency "httparty", [">= 0.8.3"]
  s.add_development_dependency "rspec", [">= 2.10.0"]
  s.summary     = "A convenience wrapper for the fb_graph gem for commonly used use-cases."
  s.description = "Simplifies commonly used Facebook Open Graph use-cases like generating an auth_url, getting an access_token and creating a user based on their Facebook user-info."
  s.authors     = ["critzjm"]
  s.email       = 'john.critz@gmail.com'
  s.files       = ["lib/fb_burrito.rb"]
  s.homepage    = 'http://rubygems.org/gems/fb_burrito'
end