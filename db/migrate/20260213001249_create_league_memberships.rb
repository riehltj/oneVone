class CreateLeagueMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :league_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :league, null: false, foreign_key: true
      t.decimal :dupr_rating, precision: 3, scale: 1
      t.string :status, default: "active", null: false

      t.timestamps
    end
    add_index :league_memberships, %i[user_id league_id], unique: true
  end
end
