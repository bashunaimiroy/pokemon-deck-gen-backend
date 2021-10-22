class CardDeckInclusion < ApplicationRecord
    # Contains enough data to display a brief summary in the Deck's Card List.
    validates :deck_id, presence: true
    validates :card_id, presence: true
    validates :card_name, presence: true
    validates :card_supertype, presence: true
    validates :quantity, presence: true
    
    has_one :deck

end
