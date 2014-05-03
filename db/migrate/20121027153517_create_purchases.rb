class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|

      f.string :details
      t.string :notes
      t.float :paid
      t.timestamps

      t.references :event
      t.references :person
    end

    create_table :product_items_purchases, :id => false do |t|
      t.integer :product_item_id
      t.integer :purchase_id
    end
  end
end
