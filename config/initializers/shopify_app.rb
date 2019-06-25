ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = "bb4b8a63f665d03b840e10969ed5ea5b"
  config.secret = "8e230557c774a1265435026e6c69b4b3"
  config.old_secret = "<old_secret>"
  config.scope = "read_products" # Consult this page for more scope options:
                                 # https://help.shopify.com/en/api/getting-started/authentication/oauth/scopes
  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = "2019-04"
  config.session_repository = Shop
end
