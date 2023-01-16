class AddEmailToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :email, :string
  end
end
