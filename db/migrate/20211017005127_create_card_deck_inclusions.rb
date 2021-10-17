class CreateCardDeckInclusions < ActiveRecord::Migration[6.1]
  def change
    create_table :card_deck_inclusions, id:false do |t|
      t.references(:card, null: false, type: :string, index: false, foreign_key: true)
      t.references(:deck, null: false, foreign_key: true)
      t.integer :quantity
      t.timestamps
    end
  end
end
