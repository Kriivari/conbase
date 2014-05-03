class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
