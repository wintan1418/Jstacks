class AddStripeIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :stripe_charge_id, :string
  end
end
