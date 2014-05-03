class Statusname < ActiveRecord::Base
  has_many :people_persongroups
  has_many :programs
  has_many :line_items
  set_primary_key "status"

  def to_s
    name
  end

end
