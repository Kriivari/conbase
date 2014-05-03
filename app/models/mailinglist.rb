class Mailinglist < ActiveRecord::Base
  has_many :persongroups
  has_many :mailinglists
  belongs_to :mailinglists, :foreign_key => 'parent_id'
  cattr_reader :per_page
  @@per_page = 10

  def to_s
    self.name
  end
end
