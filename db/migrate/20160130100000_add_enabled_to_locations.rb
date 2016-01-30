class AddVideoRightsToPrograms < ActiveRecord::Migration
  def change
    change_table :locations do |t|
      t.boolean :enabled
    end
  end
end
