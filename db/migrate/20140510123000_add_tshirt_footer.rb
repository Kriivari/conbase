class AddBillingAddress < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :tshirt_footer

    end
  end
end
