class AddPaymentRefToUploads < ActiveRecord::Migration[7.0]
  def change
    add_reference :uploads, :payment, null: false, foreign_key: true
  end
end
