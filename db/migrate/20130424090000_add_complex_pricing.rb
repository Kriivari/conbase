class AddComplexPricing < ActiveRecord::Migration
  def change
    change_table :product_types do |t|
      t.float :secondprice

    end
  end
end
