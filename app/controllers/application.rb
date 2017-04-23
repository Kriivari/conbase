# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class Application < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => 'bdca39a300969d16307cdd56156b2031'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  #filter_parameter_logging :password

  before_filter :environment

  def environment
    ev = ENV['EVENT']
    if ev == nil
      @event = Event.where(:ispublic => true).limit(1).first()
    else
      @event = Event.where(:ispublic => true, :name => ev).limit(1).first()
    end
  end

  def basic_authorize
    unless session[:user_id]
      flash[:notice] = "Kirjaudu sisään!"
      redirect_to(:controller => "login", :action => "login")
    end
    @user = Person.find(session[:user_id])
  end

  def authorize
    @user = verify
    if @user == nil
      flash[:notice] = "Kirjaudu sisään!"
      redirect_to(:controller => "login", :action => "login")
    end
  end

  def verify
    return Person.first(:conditions => ["id=? and password is not null and id in (select person_id from people_persongroups where persongroup_id in (select id from persongroups where (admin=true or wikiaccess=true) and event_id=?) and status = -1)", session[:user_id], @event.id])
  end

  def canedit
    for group in @user.people_persongroups
      if group.persongroup.event.id == @event.id && group.persongroup.admin
        return true
      end
    end
    return false
  end

  def yesno( game, grp )
    if game.programgroups.include?( grp )
      return "Kyllä / Yes"
    end
    return "Ei / No"
  end
end
