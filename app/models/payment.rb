class Payment < ApplicationRecord
  belongs_to :user
  has_many :uploads
  validates :email, presence: true
end
