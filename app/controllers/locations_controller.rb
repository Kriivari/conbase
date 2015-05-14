class LocationsController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @locations = Location.paginate :page => params[:page], :conditions => ["event_id in (select id from events where name=?)", @event.name], :order => 'start_time DESC, name'
  end

  def show
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
    @location.start_time = @event.starttime
    @location.end_time = @event.endtime
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    @location = Location.new(params[:location])
    @location.event = @event

    if @location.save
      flash[:notice] = 'Location was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @location = Location.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice] = 'Location was successfully updated.'
      redirect_to :action => 'show', :id => @location
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    Location.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
