class CreateLeagues < ActiveRecord::Migration[8.1]
  def change
    create_table :leagues do |t|
      t.string :name
      t.string :city
      t.string :region
      t.decimal :rating_min, precision: 3, scale: 1
      t.decimal :rating_max, precision: 3, scale: 1
      t.string :prize_description
      t.integer :monthly_price_cents

      t.timestamps
    end
  end
end
