class CreateCards < ActiveRecord::Migration[6.1]
  def change
    create_table :cards, id: false do |t|
      t.string :id, primary_key: true # uses the Card ID from the Pokemon TCG database, not default auto-incremented integer.
      t.string :name
      t.string :supertype
      t.datetime :created_at, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :updated_at, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
