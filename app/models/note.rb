class Note < ActiveRecord::Base
  belongs_to :event
  cattr_reader :per_page
  @@per_page = 10
end
