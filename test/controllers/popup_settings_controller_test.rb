require 'test_helper'

class PopupSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @popup_setting = popup_settings(:one)
  end

  test "should get index" do
    get popup_settings_url
    assert_response :success
  end

  test "should get new" do
    get new_popup_setting_url
    assert_response :success
  end

  test "should create popup_setting" do
    assert_difference('PopupSetting.count') do
      post popup_settings_url, params: { popup_setting: { cart_amount: @popup_setting.cart_amount, position: @popup_setting.position, shop_id: @popup_setting.shop_id, status: @popup_setting.status } }
    end

    assert_redirected_to popup_setting_url(PopupSetting.last)
  end

  test "should show popup_setting" do
    get popup_setting_url(@popup_setting)
    assert_response :success
  end

  test "should get edit" do
    get edit_popup_setting_url(@popup_setting)
    assert_response :success
  end

  test "should update popup_setting" do
    patch popup_setting_url(@popup_setting), params: { popup_setting: { cart_amount: @popup_setting.cart_amount, position: @popup_setting.position, shop_id: @popup_setting.shop_id, status: @popup_setting.status } }
    assert_redirected_to popup_setting_url(@popup_setting)
  end

  test "should destroy popup_setting" do
    assert_difference('PopupSetting.count', -1) do
      delete popup_setting_url(@popup_setting)
    end

    assert_redirected_to popup_settings_url
  end
end
