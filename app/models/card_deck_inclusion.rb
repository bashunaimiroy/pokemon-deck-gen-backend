class CardDeckInclusion < ApplicationRecord
    # Contains enough data to display a brief summary in the Deck's Card List.
    has_one :deck
end
