class AddScheduledAtAndLocationToMatches < ActiveRecord::Migration[8.1]
  def change
    add_column :matches, :scheduled_at, :datetime
    add_column :matches, :location, :string
    add_column :matches, :reminder_sent_at, :datetime
  end
end
