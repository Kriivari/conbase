class AddSlackTokenToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.string :slack_token
    end
  end
end
