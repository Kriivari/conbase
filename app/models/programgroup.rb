class Programgroup < ActiveRecord::Base
  belongs_to :mailinglist
  has_and_belongs_to_many :programs, :join_table => 'programs_programgroups'
  cattr_reader :per_page
  @@per_page = 10
end
