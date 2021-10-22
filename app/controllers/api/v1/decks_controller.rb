module API
    module V1
        class DecksController < ApplicationController
            def index
                @decks = Deck.where(nil)
                @decks = @decks.filter_by_pokemon_type(index_params[:filter_by_pokemon_type]) if index_params[:filter_by_pokemon_type].present?
                @decks = @decks.order("created_at DESC")

                # TODO: Refactor to scale for further filtering types
                message = params.has_key?(:filter_by_pokemon_type) ? "Decks, filtered by type: #{index_params[:filter_by_pokemon_type]}" : "All Decks"
                # TODO: add Pagination
                render json: { 
                    status: 'SUCCESS', 
                    message: message, 
                    decks: @decks
                }, 
                status: :ok
            end

            def show
                deck_id = params[:id]
                @deck = Deck.find(deck_id)
                @inclusions = @deck.card_deck_inclusions
                render json: { 
                    status: 'SUCCESS', 
                    message: "here is deck ##{deck_id}", 
                    deck: @deck, 
                    inclusions: @inclusions
                }, status: :ok
            end

            def create
                #  * redirect user to deck details page?
                cards_to_include = get_randomised_cards(deck_creation_params[:pokemon_type], deck_creation_params[:number_of_pokemon].to_i)

                @deck = Deck.new({pokemon_type: deck_creation_params[:pokemon_type]})
                
                if @deck.save
                    cards_to_include.each do |card_id, inclusion|
                        # create a relationship between cards and deck
                        CardDeckInclusion.create!({ 
                            deck_id: @deck.id,
                            card_id: inclusion[:card].id, 
                            card_name: inclusion[:card].name,
                            card_supertype: inclusion[:card].supertype,
                            quantity: inclusion[:quantity], 
                        })
                    end
                    render json: { 
                        status: "SUCCESS", 
                        message: "Created a deck of type #{deck_creation_params[:pokemon_type]}", 
                        deck: @deck 
                    }, status: :ok
                else
                    render json: { status: "ERROR", message: "Was unable to create deck", errors: @deck.errors }, status: :unprocessable_entity
                end 
            end
            
            private

            def get_randomised_cards(type, number_of_pokemon)
                #  Get random cards
                pokemon_cards = Pokemon::Card.where(q: "types:#{type} supertype:Pokemon")
                energy_cards = Pokemon::Card.where(q: "name:\"#{type} Energy\" supertype:Energy")
                trainer_cards = Pokemon::Card.where(q:"supertype:Trainer")
                
                # Append Set Name to the Energy Card names, to distinguish them
                # E.g. "Grass Energy (XY)" vs "Grass Energy (Sword and Shield)"
                energy_cards = energy_cards.map { |card| 
                    card.name = "#{card.name} (#{card.set.name})"
                    card
                }

                # Determine number of trainer cards to add to deck
                number_of_trainer_cards_in_deck = Deck::CONSTRAINTS[:deck_size] - Deck::CONSTRAINTS[:energy_card_count] - number_of_pokemon
                
                # Filter duplicates, only take first of each pokemon/trainer cards with same name
                unique_pokemon = pokemon_cards.uniq { |card| card.name }
                unique_trainers = trainer_cards.uniq { |card| card.name }
                
                # TODO: Allow different pokemon/trainer cards of same name, up to 4
                # possibly by adding Card Name to deck cards, and to Card_Deck_inclusion model
                
                # Deck Cards will be a hash where key is Card ID, and value is Quantity in Deck.
                
                deck_cards = {}
                random_pokemon_cards = get_random_cards_from_set(unique_pokemon, number_of_pokemon)
                random_energy_cards = get_random_cards_from_set(energy_cards, Deck::CONSTRAINTS[:energy_card_count], Deck::CONSTRAINTS[:energy_card_count])
                random_trainer_cards = get_random_cards_from_set(unique_trainers, number_of_trainer_cards_in_deck)
                
                deck_cards.merge!(random_pokemon_cards, random_energy_cards, random_trainer_cards)

                return deck_cards
            end

            def get_random_cards_from_set(card_set, number_of_cards, max_quantity_per_card = 4)
                
                cards_output = {}
                
                # select random indices within the array of cards, and return the element at that index.
                number_of_cards.times {
                    card_found = false
                    while (!card_found) do
                        random_index = rand(card_set.size)
                        card_to_add = card_set[random_index]
                        
                        # Insert card, or increment quantity.
                        # If we've already added the max quantity allowed for this card, loop again with another random card.
                        
                        if !cards_output.has_key?(card_to_add.id)
                            card_found = true
                            cards_output[card_to_add.id] = {card: card_to_add, quantity: 1}
                        elsif cards_output[card_to_add.id][:quantity] < max_quantity_per_card
                            card_found = true
                            cards_output[card_to_add.id][:quantity] += 1
                        end
                    end
                }

                return cards_output
            end
            
            def index_params
                # TODO: See if we can remove :format
                params.permit(:format, :filter_by_pokemon_type)
            end

            def deck_creation_params
                # TODO: See if we can remove :format
                params.permit(:format, :pokemon_type, :number_of_pokemon)
            end
        end
    end
end
