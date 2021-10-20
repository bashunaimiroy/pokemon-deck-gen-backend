class Deck < ApplicationRecord
    # constants
    CONSTRAINTS = {
        deck_size: 60,
        energy_card_count: 10
    }

    scope :filter_by_pokemon_type, -> (pokemon_type) { where pokemon_type: pokemon_type }
    validates :pokemon_type, presence: true
    has_many :card_deck_inclusions
    has_many :cards, through: :card_deck_inclusions
end
