module API
    module V1
        class CardsController < ApplicationController
            def show
                card_id = params[:id]
                @card = Pokemon::Card.find(card_id)
                render json: { 
                    status: 'SUCCESS', 
                    message: "Card with ID #{card_id} found", 
                    data: @card
                }, status: :ok
            end
        end
    end
end
