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

        function start(){
          window.loadScript = function(url, callback) {
            var script = document.createElement(\"script\");
            script.type = \"text/javascript\";
            // If the browser is Internet Explorer
            if (script.readyState){
              script.onreadystatechange = function() {
                if (script.readyState == \"loaded\" || script.readyState == \"complete\") {
                  script.onreadystatechange = null;
                  callback();
                }
              };
              // For any other browser
            } else {
              script.onload = function() {
                callback();
              };
            }
            script.src = url;
            document.getElementsByTagName(\"head\")[0].appendChild(script);
          };
          window.bAnimateStart = function($) {
            console.log('bAnimate Start.....');
            $.ajax({
              type:'GET',
              url: window.banimate.app_url+'/frontend/get_banimate_details',
              data : {shopify_domain : window.banimate.shopify_domain},
              crossDomain: true,
              success:function(data){
                var banimate_cart_amount = data.cart_amount;
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
                            alert('success'); 
                            $('.banimate_wrappar').show();
                            $('body').addClass('banimate_wrappar_open');
                            $(document).on('click', '.banimate_close', function(event) {
                              window.location.href = '/cart';
                              $('body').removeClass('banimate_wrappar_open');
                            });
                          }
                        });
                      }
                    });
                  });
                }
              }
            });
          }
        }
        start();

        if ((typeof(jQuery) == 'undefined') || (parseInt(jQuery.fn.jquery) == 3 && parseFloat(jQuery.fn.jquery.replace(/^1\./,"")) < 4.0)) {
          console.log('Inside if in banimate');
          loadScript('https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.0/jquery.min.js', function() {
            jQuery340 = jQuery.noConflict(true);
              bAnimateStart(jQuery340);
          });
        }else{  
          console.log('Inside else in banimate');
              bAnimateStart(jQuery);
        }
      </script>

      <div class='banimate_wrappar' style='display:none;''>
        <div class='popup-overlay'></div>
        <div class='banimate_popupBox'>
          <div class='banimate_mainHead'>       
            <p class='banimate_popup-heading'>Free shipping</p>
            <span class='banimate_close'>&times;</span>        
          </div> 

          <div class='banimate_mainContent'>
            <div class='popup-Image'>
              <img src='https://image.shutterstock.com/image-vector/congratulations-hand-lettering-modern-brush-260nw-532058731.jpg'>
            </div>
          </div>

          <div class='banimate_popup-footer'>
            <button type='button' class='btn btn-success subscribe-btn'  style='background: rgba(92, 184, 92, 1);color: rgba(255, 255, 255, 1);'>Continue</button> 
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
        .banimate_popupBox .banimate_mainContent h4{
          font-size:18px;
          margin:0;
        }
        .banimate_popupBox{
          background-color: #fefefe;
          margin: auto;
          border: 1px solid #888;
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
        .banimate_popupBox .banimate_mainHead{
          display: flex;
          align-items:center;
          justify-content:space-between;
          padding: 20px;
          border-bottom: 1px solid #e5e5e5;
        }
        .popup-overlay {
          background: rgba(0,0,0,0.7);
          position: fixed;
          left: 0;
          right: 0;
          top: 0;
          bottom: 0;
          display: none;
        }
        .banimate_wrappar_open .popup-overlay {
          display: block
        }
        .banimate_close {
          color: #aaaaaa;    
          font-size: 28px;
          line-height: 18px;
          font-weight: bold;   
        }
        .banimate_close:hover,
        .banimate_close:focus {
          color: #000;
          text-decoration: none;
          cursor: pointer;
        }
        .banimate_popupBox .banimate_popup-heading{
          font-size:18px;   
          font-weight:bold;
        }
        .banimate_popupBox .banimate_mainContent{
          padding:20px;
          border-bottom: 1px solid #e5e5e5;
        }
        .banimate_mainContent .popup-Image{
          text-align:center;
          padding:20px 0;
        }
        .banimate_mainContent .popup-Image img{
          width:280px;
          height:215px;
          object-fit:cover;
        }
        .banimate_popupBox .banimate_popup-footer{
          padding:20px;
          text-align:right;
        }
        .banimate_popup-footer .subscribe-btn{
          border: 0 none;
          color: #fff;
          background-color: #5cb85c;
          border-color: #4cae4c;
          display: inline-block;
          padding: 6px 12px;
          margin-bottom: 0;
          font-size: 14px;
          font-weight: normal;
          line-height: 1.42857143;
          text-align: center;
          white-space: nowrap;
          vertical-align: middle;
          border-radius: 4px;
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
