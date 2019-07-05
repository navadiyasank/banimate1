require "application_system_test_case"

class PopupSettingsTest < ApplicationSystemTestCase
  setup do
    @popup_setting = popup_settings(:one)
  end

  test "visiting the index" do
    visit popup_settings_url
    assert_selector "h1", text: "Popup Settings"
  end

  test "creating a Popup setting" do
    visit popup_settings_url
    click_on "New Popup Setting"

    fill_in "Cart amount", with: @popup_setting.cart_amount
    fill_in "Position", with: @popup_setting.position
    fill_in "Shop", with: @popup_setting.shop_id
    check "Status" if @popup_setting.status
    click_on "Create Popup setting"

    assert_text "Popup setting was successfully created"
    click_on "Back"
  end

  test "updating a Popup setting" do
    visit popup_settings_url
    click_on "Edit", match: :first

    fill_in "Cart amount", with: @popup_setting.cart_amount
    fill_in "Position", with: @popup_setting.position
    fill_in "Shop", with: @popup_setting.shop_id
    check "Status" if @popup_setting.status
    click_on "Update Popup setting"

    assert_text "Popup setting was successfully updated"
    click_on "Back"
  end

  test "destroying a Popup setting" do
    visit popup_settings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Popup setting was successfully destroyed"
  end
end
