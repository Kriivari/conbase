class AddExhibitorReference < ActiveRecord::Migration
  def change
    change_table :exhibitors do |t|
      t.string :customer_reference

    end
  end
end
