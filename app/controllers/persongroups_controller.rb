class PersongroupsController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  def list
    @persongroups = Persongroup.paginate :page => params[:page], :conditions => ["event_id in (select id from events where name=?)", @event.name], :order => 'event_id desc, name'
  end

  def show
    @persongroup = Persongroup.find(params[:id])
  end

  def new
    @persongroup = Persongroup.new
    @mailinglists = Mailinglist.all
  end

  def create
    if ! canedit
      redirect_to :action => 'index'
    end
    @persongroup = Persongroup.new(params[:persongroup])
    @persongroup.event = @event
    if @persongroup.save
      flash[:notice] = 'Persongroup was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @persongroup = Persongroup.find(params[:id])
    @mailinglists = Mailinglist.all
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @persongroup = Persongroup.find(params[:id])
    if @persongroup.update_attributes(params[:persongroup])
      flash[:notice] = 'Persongroup was successfully updated.'
      redirect_to :action => 'show', :id => @persongroup
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    Persongroup.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  def email
    if ! canedit
      redirect_to :action => 'list'
    end
    @persongroup = Persongroup.find(params[:id])
    subject = params[:email][:subject]
    body = params[:email][:body]

    emails = []
    persons = []
    for person in @persongroup.people_persongroups.sort_by { |g| g.person.fullname }
      if person.status == -1 && person.person != nil && ! persons.include?( person.person )
        unless person.person.primary_email.end_with?("example.com") || person.person.primary_email.end_with?(".invalid")
          emails << person.person.primary_email
        end
        persons << person
      end
    end

    GenericMailer.email(@event,@user.primary_email,emails.join(","),subject,body).deliver

    redirect_to :controller => params[:next_controller], :action => params[:next_action], :id => @persongroup.id
  end
end
