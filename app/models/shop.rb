class Shop < ActiveRecord::Base
  include ShopifyApp::SessionStorage
  has_one :popup_setting, dependent: :destroy
  after_create :set_configuration
  after_update :set_configuration, if: ->(obj){ obj.saved_change_to_shopify_token? }

  def api_version
    ShopifyApp.configuration.api_version
  end

  def set_configuration
  	unless popup_setting.present?
  		create_popup_setting
  	end
    asset_integrate
  end

  #this will creates snippet in current theme and include snippet in theme.liquid
  def asset_integrate
  	ShopifyAPI::Base.site = "https://#{ShopifyApp.configuration.api_key}:#{self.shopify_token}@#{self.shopify_domain}/admin/"
    ShopifyAPI::Base.api_version = ShopifyApp.configuration.api_version
    @theme = ShopifyAPI::Theme.find(:all).where(role: 'main').first
    @asset = ShopifyAPI::Asset.create(key: 'snippets/banimate.liquid', value: 'This is for testing ', theme_id: @theme.id) rescue nil

    @asset = ShopifyAPI::Asset.find('layout/theme.liquid', :params => { :theme_id => @theme.id}) rescue nil
    if @asset.present?
      @asset_value = @asset.value
      @asset.update_attributes(theme_id: @theme.id,value: @asset_value.gsub("</body>","{% comment %}This is from banimate.{% endcomment %}{% include 'banimate' %}</body>")) unless @asset_value.include?("{% include 'banimate' %}")
    end
  end

end
