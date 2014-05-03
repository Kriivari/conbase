class ProgramsOrganizer < ActiveRecord::Base
  belongs_to :person
  belongs_to :program
  belongs_to :statusname, :class_name => "Statusname", :foreign_key => "orgtype"
end
