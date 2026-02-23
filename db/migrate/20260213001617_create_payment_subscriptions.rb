class CreatePaymentSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :league, null: false, foreign_key: true
      t.string :stripe_subscription_id
      t.string :status, default: "active", null: false

      t.timestamps
    end
    add_index :payment_subscriptions, %i[user_id league_id], unique: true
  end
end
