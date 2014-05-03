class ProgramsEventsAttribute < ActiveRecord::Base
  belongs_to :program
  belongs_to :event
  belongs_to :attribute
end
