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
    @asset = ShopifyAPI::Asset.create(key: 'snippets/banimate.liquid', value: "
      <script>
        window.banimate = {
          shopify_domain: '{{shop.permanent_domain}}',
          app_url: '#{ENV['DOMAIN']}',
          cart_total: 0
        }
        window.banimate.cart_total = {{ cart.total_price }}
        console.log(window.banimate.cart)
        $.ajax({
          type:'GET',
          url: window.banimate.app_url+'/frontend/get_banimate_details',
          data : {shopify_domain : window.banimate.shopify_domain},
          crossDomain: true,
          success:function(data){
            var banimate_cart_amount = data.cart_amount;
            var banimate_position = data.position;
            console.log('response==',data);
            if(banimate_cart_amount > 0){
              var selectors = $(\"input[name='add'] , button[name='add'], #add-to-cart, #AddToCartText ,#AddToCart, .product-form__cart-submit\")
              selectors.addClass('banimate-atc-btn');
              $(document).on('click', '.banimate-atc-btn', function(event) {
                event.preventDefault();
                $.ajax({
                  type: 'POST', 
                  url: '/cart/add.js',
                  dataType: 'json', 
                  data: $(this).parents('form').serialize(),
                  success:function(data){
                    $.getJSON('/cart.js', function(cart) {
                      var cart_total = parseFloat(cart.total_price/100)
                      console.log(cart_total);
                      if(cart_total >= banimate_cart_amount){
                        $('.banimate_popupBox').addClass(banimate_position);
                        $('.banimate_wrappar.achieved').show();
                        $('body').addClass('banimate_wrappar_open');
                      }
                    });
                  }
                });
              });
            }
          }
        });
      </script>

      <div class='banimate_wrappar achieved' style='display:none;'>
        <div class='banimate_popupBox'>
          <div class='banimate_mainContent'>
            <div class='popup-Image'>
              <img src='#{ENV['DOMAIN']}/banimate.gif'>
            </div>
          </div>
        </div>
      </div>

      <style type='text/css'>
        *{
          box-sizing: border-box;
        }
        .banimate_wrappar_open{
          overflow: hidden;
        }
        .banimate_wrappar{
          position: fixed;
          left: 0;
          right: 0;
          top: 0;
          bottom: 0;
          overflow: auto;
          padding: 0 0;
          z-index: 999;
        }
        .banimate_popupBox p{
          margin:0;
          font-size:14px;
        }
        .banimate_popupBox{
          background-color: transparent;
          margin: auto;
          max-width: 600px;
          width: 100%;
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%) scale(0.5);
          z-index: 1000;
          opacity: 0;
          visibility: hidden;
        }
        .banimate_wrappar_open .banimate_popupBox{
          transition: all 0.3s;
          transform: translate(-50%, -50%) scale(1);
          opacity: 1;
          visibility: visible;
        }
        .banimate_popupBox .banimate_mainContent{
          padding:20px;
        }
        .banimate_mainContent .popup-Image{
          text-align:center;
          padding:20px 0;
        }
        .banimate_mainContent .popup-Image img{
          object-fit:cover;
        }
        .banimate_popupBox.bottom_left{
          left: 0;
          top: auto;
          bottom: 0;
          transform: translate(0, 0%) scale(0.5);
        }
        .banimate_wrappar_open .bottom_left{
          transform: translate(0, 0) scale(1) !important;
          left: 0;
          top: auto;
          bottom: 0;
        }
        .banimate_popupBox.bottom_right{
          right: 0;
          top: auto;
          bottom: 0;
          transform: translate(0, 0%) scale(0.5);
          margin: 0 0 0 auto;
        }
        .banimate_wrappar_open .bottom_right{
          transform: translate(0, 0) scale(1) !important;
          right: 0;
          top: auto;
          bottom: 0;
        }
        @media screen and (max-width:767px){
          .banimate_popupBox{
            max-width:90%;
            max-height:80vh;
            overflow: auto;
          }
        }
      </style>

    ", theme_id: @theme.id) rescue nil

    @asset = ShopifyAPI::Asset.find('layout/theme.liquid', :params => { :theme_id => @theme.id}) rescue nil
    if @asset.present?
      @asset_value = @asset.value
      @asset.update_attributes(theme_id: @theme.id,value: @asset_value.gsub("</body>","{% comment %}This is from banimate.{% endcomment %}{% include 'banimate' %}</body>")) unless @asset_value.include?("{% include 'banimate' %}")
    end
  end

end
