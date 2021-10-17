class CreateCards < ActiveRecord::Migration[6.1]
  def change
    create_table :cards, id: false do |t|
      t.string :id, primary_key: true # uses the Card ID from the Pokemon TCG database, not default auto-incremented integer.
      t.string :name
      t.timestamps
    end
  end
end
