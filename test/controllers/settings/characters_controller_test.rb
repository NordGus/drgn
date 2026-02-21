require "test_helper"

class Settings::CharactersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @character = characters(:luffy)
  end

  def teardown
    sign_out
  end

  test "should get index" do
    sign_in_as @character

    get settings_character_url
    assert_response :success
  end

  test "should show character" do
    sign_in_as @character

    get settings_character_url
    assert_response :success
  end

  test "should update character" do
    sign_in_as @character

    patch settings_character_url, params: { character: {} }
    assert_redirected_to settings_character_url
  end

  test "should destroy character" do
    sign_in_as @character

    assert_difference("Character.count", -1) do
      delete settings_character_url
    end

    assert_redirected_to session_url
  end
end
