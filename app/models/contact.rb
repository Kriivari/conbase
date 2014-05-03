class Contact < ActiveRecord::Base
  belongs_to :person
  cattr_reader :per_page
  @@per_page = 10
end
