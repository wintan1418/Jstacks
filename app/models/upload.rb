class Upload < ApplicationRecord
  belongs_to :user
  belongs_to :payment
  has_many_attached :images

end
