# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

case Rails.env
when 'development'

  pokemon_types = [
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
  
  pokemon_types.each do |type| 
    # create a deck for each type
    deck_of_type = Deck.create(pokemon_type: type)
    
    # Create energy and pokemon cards for each type, and include them in the appropriate deck
    energy_card_of_type = Card.create(name: "#{type} Energy", id: "#{type}-en")
    pokemon_card_of_type = Card.create(name: "#{type}-type Pokemon", id: "#{type}-pk")
    CardDeckInclusion.create(deck_id: deck_of_type.id, card_id: energy_card_of_type.id, quantity: 10 )
    CardDeckInclusion.create(deck_id: deck_of_type.id, card_id: pokemon_card_of_type.id, quantity: 1 )
  end
  
end