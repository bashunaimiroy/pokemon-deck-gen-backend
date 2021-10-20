module API
    module V1
        class DecksController < ApplicationController
            def index
                @decks = Deck.where(nil)
                @decks = @decks.filter_by_pokemon_type(params[:filter_by_pokemon_type]) if params[:filter_by_pokemon_type].present?
                @decks = @decks.order("created_at DESC")

                # TODO: Refactor to scale for further filtering types
                message = params.has_key?(:filter_by_pokemon_type) ? "Decks, filtered by type: #{params[:filter_by_pokemon_type]}" : "All Decks"
                # TODO: add Pagination
                render json: { 
                    status: 'SUCCESS', 
                    message: message, 
                    data: {decks: @decks}
                }, 
                status: :ok
            end

            def show
                deck_id = params[:id]
                @deck = Deck.find(deck_id)
                # TODO: Determine why @deck.cards is not working-
                # Unknown Column `cards`.`card_deck_inclusion.id`
                # Seems to be a problem with association in Card model
                @cards = @deck.card_deck_inclusions.map {|cdi| Card.find(cdi.card_id)}
                render json: { 
                    status: 'SUCCESS', 
                    message: "here is deck ##{deck_id}", 
                    data: { 
                        deck: @deck, 
                        cards: @cards
                    }
                }, status: :ok
            end

            def create
                #  * redirect user to deck details page?
                cards_in_deck = get_randomised_cards(params[:pokemon_type], params[:number_of_pokemon].to_i)

                @deck = Deck.new({pokemon_type: params[:pokemon_type]})
                

                if @deck.save
                    cards_in_deck.each do |card_id, quantity|
                        # create a relationship between cards and deck
                        CardDeckInclusion.create!({ card_id: card_id, deck_id: @deck.id, quantity: quantity })
                    end
                    render json: { status: "SUCCESS", message: "Created a deck of type #{params[:pokemon_type]}", data: @deck }, status: :ok
                else
                    render json: { status: "ERROR", message: "Was unable to create deck", data: @deck.errors }, status: :unprocessable_entity
                end 
            end
            
            private

            def get_randomised_cards(type, number_of_pokemon)
                #  Get random cards
                # TODO: use existing Card Records to optimise; skip repetitive API calls
                pokemon_cards = Pokemon::Card.where(q: "types:#{type} supertype:Pokemon")
                energy_cards = Pokemon::Card.where(q: "name:\"#{type} Energy\" supertype:Energy")
                trainer_cards = Pokemon::Card.where(q:"supertype:Trainer")
                
                # insert or update Card Records, referenced via inclusions
                cards_retrieved = pokemon_cards + energy_cards + trainer_cards
                card_data_to_upsert = cards_retrieved.map{ |card| {
                    id: card.id, 
                    name: card.name, 
                    supertype: card.supertype,
                    created_at: Time.now 
                    }
                } 
                # TODO: Check if upsertion is needed- limit to once a day/week/month
                Card.upsert_all(card_data_to_upsert)

                number_of_trainer_cards_in_deck = Deck::CONSTRAINTS[:deck_size] - Deck::CONSTRAINTS[:energy_card_count] - number_of_pokemon
                
                # Only take first of each pokemon/trainer cards with that name
                unique_pokemon = pokemon_cards.uniq{ |card| card.name }
                unique_trainers = trainer_cards.uniq{ |card| card.name }
                
                # TODO: Allow different pokemon/trainer cards of same name, up to 4
                # possibly by adding Card Name to deck cards, and to Card_Deck_inclusion model
                
                # Deck Cards will be a hash where key is Card ID, and value is Quantity in Deck.
                
                deck_cards = {}
                pokemon_cards = get_random_cards_from_set(unique_pokemon, number_of_pokemon)
                energy_cards = get_random_cards_from_set(energy_cards, Deck::CONSTRAINTS[:energy_card_count], Deck::CONSTRAINTS[:energy_card_count])
                trainer_cards = get_random_cards_from_set(unique_trainers, number_of_trainer_cards_in_deck)
                
                deck_cards.merge!(pokemon_cards, energy_cards, trainer_cards)

                return deck_cards
            end

            def get_random_cards_from_set(card_set, number_of_cards, max_quantity_per_card = 4)
                card_set_clone = card_set.clone
                randomised_cards = {}
                
                # select random indices within the array of cards, and return elements at those indices.

                number_of_cards.times {
                    card_to_add_index = rand(card_set_clone.size)
                    card_to_add = card_set_clone[card_to_add_index]
                    
                    if randomised_cards.has_key?(card_to_add.id)
                        randomised_cards[card_to_add.id] += 1
                        # if we've already added the max quantity allowed for this card, make sure it's not randomly picked again.
                        if randomised_cards[card_to_add.id] >= max_quantity_per_card
                            card_set_clone = card_set_clone.reject.with_index{|v, i| i == card_to_add_index }
                        end
                    else
                        randomised_cards[card_to_add.id] = 1
                    end
                }

                return randomised_cards
            end
            
            def index_params
                params.permit(:filter_by)
            end

            def creation_params
                # TODO: figure out the correct way to handle and filter params
                params.require(:deck).permit(:pokemon_type, :number_of_pokemon)
            end
        end
    end
end
