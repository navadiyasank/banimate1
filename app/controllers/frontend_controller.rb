class FrontendController < ApplicationController
	protect_from_forgery with: :null_session
	#Returns the popup settings for specific shop
	def get_banimate_details
		@shop = Shop.find_by_shopify_domain(params[:shopify_domain])
		popup_setting = @shop.popup_setting
		if popup_setting&.status
			render json: {cart_amount: popup_setting&.cart_amount.to_f,position: popup_setting&.position.to_s,msg: "success"} and return
		else
			render json: { msg: "No data found" } and return
		end
	end
end
