class UpdateExhibitors < ActiveRecord::Migration
  def change
    change_table :exhibitors do |t|
      t.integer :rebate
      t.float :paid
      t.date :invoicedate
      t.date :duedate

    end
  end
end
