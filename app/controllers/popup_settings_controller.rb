class PopupSettingsController < ShopifyApp::AuthenticatedController
  before_action :set_current_shop
  before_action :set_popup_setting, only: [:edit, :update]

  # GET /popup_settings/1/edit
  def edit
  end

  # PATCH/PUT /popup_settings/1
  # PATCH/PUT /popup_settings/1.json
  def update
    respond_to do |format|
      if @popup_setting.update(popup_setting_params)
        format.html { redirect_to edit_popup_setting_path(@popup_setting), notice: 'Popup setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @popup_setting }
      else
        format.html { render :edit }
        format.json { render json: @popup_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_popup_setting
      @popup_setting = @shop.popup_setting
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def popup_setting_params
      params.require(:popup_setting).permit(:position, :status, :shop_id, :cart_amount)
    end

    def set_current_shop
      # @current_shop = ShopifyAPI::Shop.current
      # @shop = Shop.find_by_shopify_domain(ShopifyAPI::Shop.current.myshopify_domain)
      @shop = Shop.last
    end
end
