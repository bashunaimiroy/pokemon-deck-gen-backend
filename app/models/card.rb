class Card < ApplicationRecord
    validates :name, presence: true
    has_many :card_deck_inclusions
    has_many :decks, through: :card_deck_inclusions
end
