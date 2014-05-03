class Location < ActiveRecord::Base
  belongs_to :event
  has_many :programitems
  cattr_reader :per_page
  @@per_page = 10

  def to_s
    name
  end

  def sorteditems
    items = self.programitems
    for i in 0..items.length-1
      for j in i+1..items.length-1
        if items[j].start_time<items[i].start_time
          t = items[j]
          items[j] = items[i]
          items[i] = t
        end
      end
    end
    return items
  end
end
