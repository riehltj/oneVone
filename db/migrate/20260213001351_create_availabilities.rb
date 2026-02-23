class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :day_of_week
      t.time :start_time
      t.time :end_time
      t.string :timezone

      t.timestamps
    end
  end
end
