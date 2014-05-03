class UpdateEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.boolean :ticketorder
      t.string :ticketfooter

    end
    Event.update_all ["ticketorder=?", false]
  end
end
