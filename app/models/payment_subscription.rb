class PaymentSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :league

  validates :status, inclusion: { in: %w[active canceled past_due] }
end
