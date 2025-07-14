class Ticket < ApplicationRecord
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :title, presence: true
  validates :received_at, presence: true
  
  before_validation :set_received_at, on: :create
  
  private
  
  def set_received_at
    self.received_at ||= Time.current
  end
end
