class NotesController < Application
  before_filter :authorize, :except => [:xml]

  def index
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @notes = Note.paginate :page => params[:page], :order => 'starttime', :conditions => ['event_id=?', @event.id]
  end

  def xml
    @notifications = Note.find_by_sql(["select distinct notes.* from notes where event_id=? and starttime<? and endtime>?", @event.id, Time.now, Time.now])
    respond_to do |format|
      format.any do
        headers["Content-Type"] = "application/xml; charset=utf-8"
        render "xml.xml", :layout => false
      end
    end
  end

  def show
    @note = Note.find(params[:id])
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(params[:note])
    @note.event = @event
    if @note.save
      flash[:notice] = 'Ilmoitus luotu onnistuneesti.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])
    if @note.update_attributes(params[:note])
      flash[:notice] = 'Ilmoitus päivitetty onnistuneesti.'
      redirect_to :action => 'show', :id => @note
    else
      render :action => 'edit'
    end
  end

  def destroy
    Note.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
