class CardDeckInclusion < ApplicationRecord
    has_one :card
    has_one :deck
end
