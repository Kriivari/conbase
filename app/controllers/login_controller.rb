class LoginController < Application
  before_filter :authorize, :except => [:login, :password, :send_password]

  def login
    if request.get?
      session[:user_id] = nil
    else
      @user = Person.new(params[:user].downcase.strip )
      logged_in_user = @user.try_to_login
      if logged_in_user
        session[:user_id] = logged_in_user.id
        redirect_to :action => "index"
      else
        flash[:notice] = "Virheellinen tunnus tai salasana."
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Kirjattu ulos."
    redirect_to(:action => "login")
  end

  def password
  end

  def send_password
    @user = Person.first(:conditions => ["primary_email=?", params[:user][:primary_email]])
    if @user && (params[:check] == "5" || params[:check].downcase == "viisi")
      password = ""
      StaffMailer.confirm("Uusi salasanasi Conbaseen on " + password, "conbase@ropecon.fi", @user.primary_email, nil, "Conbasen salasanan vaihto")
    end
  end

  def index
  end
end
