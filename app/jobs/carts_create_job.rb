class CartsCreateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
  	debugger
    shop = Shop.find_by!(shopify_domain: shop_domain)
    p "Hello Cart #{shop.name}"
  end
end