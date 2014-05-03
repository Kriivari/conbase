class MoreDetailsToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :address
      t.string :bankaccount
      t.string :businesscode
    end
  end
end
