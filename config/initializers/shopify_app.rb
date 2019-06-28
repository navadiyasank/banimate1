ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"
  config.api_key = ENV['SHOPIFY_API_KEY']
  config.secret = ENV['SHOPIFY_API_SECRET']
  config.old_secret = "<old_secret>"
  config.scope = "read_products read_orders" # Consult this page for more scope options:
                                 # https://help.shopify.com/en/api/getting-started/authentication/oauth/scopes
  config.embedded_app = true
  config.after_authenticate_job = false
  config.api_version = "2019-04"
  config.session_repository = Shop
  config.webhooks = [
    {
      topic: 'app/uninstalled',
      address: "https://797a170f.ngrok.io/webhooks/app_uninstalled",
      format: 'json'
    },
    {
      topic: 'carts/create',
      address: "https://797a170f.ngrok.io/webhooks/carts_create",
      format: 'json'
    },
    {
      topic: 'orders/paid',
      address: "https://797a170f.ngrok.io/webhooks/orders_paid",
      format: 'json'
    },
  ]
end
