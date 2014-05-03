class Purchase < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :event
  belongs_to :person
  has_and_belongs_to_many :product_types

  def reference
    return ApplicationHelper.reference( self.event.year.to_s + "01", self )
  end
end
