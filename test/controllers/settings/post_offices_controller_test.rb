require "test_helper"

class Settings::PostOfficesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post_office = mechanic_post_offices(:mechanic_post_office)
    @character = character_dungeon_masters(:luffy)

    sign_in_as(@character)
  end

  test "should show settings_post_office" do
    get settings_post_office_url
    assert_response :success
  end



  test "should update settings_post_office" do
    update_params = {
      mechanic_post_office: {
        confirmation_password: "password",
        address_attributes: { id: @post_office.address.id, value: "smtp.gmail.com" },
        port_attributes: { id: @post_office.port.id, value: @post_office.port.value },
        username_attributes: { id: @post_office.username.id, value: @post_office.username.value },
        password_attributes: { id: @post_office.password.id, value: @post_office.password.value },
        disable_configuration_errors_notification_attributes: {
          id: @post_office.disable_configuration_errors_notification.id,
          value: true
        }
      }
    }

    assert_changes -> { @post_office.reload.address.value } do
      patch settings_post_office_url, params: update_params
      assert_redirected_to settings_post_office_url
    end
  end
end
