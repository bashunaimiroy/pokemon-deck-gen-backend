module API
    module V1
        class DecksController < ApplicationController
            def index
                @decks = Deck.order("created_at DESC")
                render json: { status: 'SUCCESS', message: 'these are all of the decks', data: @decks }, status: :ok
            end
        end
    end
end
