class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.references :league, null: false, foreign_key: true
      t.references :challenger, null: false, foreign_key: { to_table: :users }
      t.references :opponent, null: false, foreign_key: { to_table: :users }
      t.string :status, default: "pending", null: false
      t.references :winner, null: true, foreign_key: { to_table: :users }
      t.string :score

      t.timestamps
    end
  end
end
