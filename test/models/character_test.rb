require "test_helper"

class CharacterTest < ActiveSupport::TestCase
  setup { @character = characters(:luffy) }

  class WhenPassingPasswordAttribute < self
    test "does not save the password" do
      @character.password = "password"

      assert @character.save
      assert_nil @character.reload.password
    end

    test "adds an error to the password attribute when it can't unlock password padlock" do
      @character.password = "invalid_password"

      assert_not @character.save
      assert_includes @character.errors[:password], "is invalid"
    end
  end
end
