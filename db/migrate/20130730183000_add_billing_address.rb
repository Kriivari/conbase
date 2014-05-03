class AddBillingAddress < ActiveRecord::Migration
  def change
    change_table :exhibitors do |t|
      t.string :billing_address

    end
  end
end
