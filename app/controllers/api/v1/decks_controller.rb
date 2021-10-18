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
                render json: { status: 'SUCCESS', message: message, data: @decks }, status: :ok
            end

            def show
                deck_id = params[:id]
                @deck = Deck.find(deck_id)
                render json: { status: 'SUCCESS', message: "here is deck ##{deck_id}", data: @deck }, status: :ok
            end

            def create
                @deck = Deck.create(creation_params)
                # TODO: 
                #  * Get random cards
                #  * associate them with Deck by creating inclusions
                #  * redirect user to deck details page?
                
                if @deck.save 
                    render json: { status: "SUCCESS", message: "Created a deck of type #{params[:pokemon_type]}", data: @deck }, status: :ok
                else
                    render json: { status: "ERROR", message: "Was unable to create deck", data: @deck.errors }, status: :unprocessable_entity
                end 
            end
            
            private
            
            def index_params
                params.permit(:filter_by)
            end

            def creation_params
                # TODO: double-check that this is the correct way to handle and filter params
                params.require(:deck).permit(:pokemon_type)
            end
        end
    end
end
