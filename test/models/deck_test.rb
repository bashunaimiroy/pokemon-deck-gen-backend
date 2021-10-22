require "test_helper"

class DeckTest < ActiveSupport::TestCase
  test "accepts types from list" do
    deck = decks(:one)
    assert deck.valid?, deck.errors.full_messages.inspect
    deck.pokemon_type = "not-a-real-pokemon-type"
    assert deck.invalid?, deck.errors.full_messages.inspect
    deck.pokemon_type = "fighting"
    assert deck.invalid?, deck.errors.full_messages.inspect
  end
end
