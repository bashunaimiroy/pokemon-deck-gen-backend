class Deck < ApplicationRecord
    # constants
    CONSTRAINTS = {
        deck_size: 60,
        energy_card_count: 10
    }
    VALID_POKEMON_TYPES = 
    [
        "Colorless",
        "Darkness",
        "Dragon",
        "Fairy",
        "Fighting",
        "Fire",
        "Grass",
        "Lightning",
        "Metal",
        "Psychic",
        "Water"
    ]

    scope :filter_by_pokemon_type, -> (pokemon_type) { where pokemon_type: pokemon_type }
    validates :pokemon_type, presence: true, inclusion: { in: VALID_POKEMON_TYPES }
    has_many :card_deck_inclusions
end
