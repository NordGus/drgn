require "test_helper"

class CharacterMailerTest < ActionMailer::TestCase
  setup { @character = characters(:luffy) }

  test "sheet_updated" do
    mail = CharacterMailer.sheet_updated(@character)
    assert_equal "Profile Updated", mail.subject
    assert_equal [ @character.contact_address ], mail.to
    assert_equal [ "from@example.com" ], mail.from
  end
end
