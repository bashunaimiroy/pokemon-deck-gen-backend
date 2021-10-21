class CreateCardDeckInclusions < ActiveRecord::Migration[6.1]
  def change
    # Store enough data to display a brief summary in the Deck's Card List.
    create_table :card_deck_inclusions do |t|
      t.references :deck, null: false, foreign_key: true
      t.string :card_id # ID from the Pokemon TCG Database
      t.string :card_name
      t.string :card_supertype
      t.integer :quantity
      t.timestamps
    end
  end
end
