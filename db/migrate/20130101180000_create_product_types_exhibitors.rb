class CreateProductTypesExhibitors < ActiveRecord::Migration
  def change
    create_table :exhibitors_product_types, :id => false do |t|
      t.integer :product_type_id
      t.integer :exhibitor_id

    end

    change_table :events do |t|
      t.remove :tableprice
      t.remove :ticketprice
    end

    change_table :exhibitors do |t|
      t.remove :tables
      t.remove :tickets
      t.remove :travelpasses
      t.remove :tablesize
    end
  end
end
