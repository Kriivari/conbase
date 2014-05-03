class Schedule < ActiveRecord::Base
  belongs_to :people_persongroup

  def delete(group,time)
    Schedule.find_by_people_persongroup_and_starttime(group,time).destroy
  end
end
