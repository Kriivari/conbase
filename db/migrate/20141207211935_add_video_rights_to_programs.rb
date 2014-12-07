class AddVideoRightsToPrograms < ActiveRecord::Migration
  def change
    change_table :programs do |t|
      t.boolean :videorights
      t.boolean :sliderights
    end
  end
end
