class Deck < ApplicationRecord
    validates :pokemon_type, presence: true
    has_many :card_deck_inclusions
    has_many :cards, through: :card_deck_inclusions
end
