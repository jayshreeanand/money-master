class Reminder < ApplicationRecord
  belongs_to :user
  belongs_to :transaction_rec

  validates :remind_at, presence: true
  validates :kind, presence: true

  enum kind: { one_time: 0, recurring: 1 }

end
