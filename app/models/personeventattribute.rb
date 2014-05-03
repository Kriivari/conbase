class Personeventattribute < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
  belongs_to :attribute
end
