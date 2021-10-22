require "test_helper"

class CardDeckInclusionTest < ActiveSupport::TestCase
  test "check validations on Card Deck Inclusions" do
    cdi = card_deck_inclusions(:one)
    assert cdi.valid? cdi.errors.full_messages.inspect
    cdi.card_name = nil
    assert cdi.invalid? cdi.errors.full_messages.inspect
  end
end
