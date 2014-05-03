class CreateProductTypes < ActiveRecord::Migration
  def change
    create_table :product_types do |t|
      t.string :name
      t.boolean :active
      t.float :price

      t.timestamps

      t.references :product
    end
  end
end
