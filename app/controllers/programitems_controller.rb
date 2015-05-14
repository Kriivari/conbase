class ProgramitemsController < Application
  before_filter :authorize
#  cache_sweeper :program_sweeper, :only => [:edit, :create]

  def index
    list
    render :action => 'list'
  end

  def list
    @programitems = Programitem.paginate :page => params[:page]
  end

  def show
    @programitem = Programitem.find(params[:id])
  end

  def new
    @programitem = Programitem.new
    @program = Program.find(params[:id])
    @locations = Location.find_by_sql(["select distinct locations.* from locations where event_id=? order by name", @program.event.id]).map { |l| [l.name, l.id] }
    @locations = [['Valitse paikka', 0]] + @locations
    firstday = @program.event.starttime
    lastday = @program.event.endtime
    firstday = Date.new( firstday.year, firstday.month, firstday.mday )
    lastday = Date.new( lastday.year, lastday.month, lastday.mday )
    @dates = []
    i = 1
    while firstday <= lastday
      @dates << [Date.new( firstday.year, firstday.month, firstday.mday )]
      i = i + 1
      firstday = firstday + 1
    end
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    if params[:loc][:value] == "0"
      flash[:notice] = 'Paikka puuttuu!'
      redirect_to :action => 'new', :id => params[:program][:id]
      return
    end
    @programitem = Programitem.new(params[:programitem])
    program = Program.find(params[:program][:id])
    @programitem.program = program
    if params[:loc] != nil
      @programitem.location = Location.find(params[:loc][:value])
    end
    startday = Date.parse( params[:starts][:value] )
    starthour = params[:starttime][:hour]
    startmin = params[:starttime][:minute]
    endday = Date.parse( params[:ends][:value] )
    endhour = params[:endtime][:hour]
    endmin = params[:endtime][:minute]
    starttime = Time.local( startday.year, startday.month, startday.mday, starthour, startmin )
    endtime = Time.local( endday.year, endday.month, endday.mday, endhour, endmin )
    @programitem.start_time = starttime
    @programitem.end_time = endtime
    if @programitem.save
      program.save
      expire_fragment('programs_xml')
      flash[:notice] = 'Ohjelmatieto lisätty.'
      if @programitem.conflict == -1
	flash[:conflict] = "Päällekäinen varaus"
      end
      redirect_to :controller => 'programs', :action => 'edit', :id => program.id
    else
      redirect_to :action => 'new', :id => program.id
    end
  end

  def edit
    @programitem = Programitem.find(params[:id])
    @locations = Location.where(:event_id => @programitem.program.event.id).order("name")
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @programitem = Programitem.find(params[:id])
    @locations = Location.where(:event_id => @programitem.program.event.id).order("name")
    if Programitem.update(params[:id], params[:programitem])
      expire_fragment('programs_xml')
      flash[:notice] = 'Programitem was successfully updated.'
      if @programitem.conflict == -1
	flash[:conflict] = "Päällekäinen varaus"
      end
      redirect_to :controller => 'programs', :action => 'edit', :id => @programitem.program.id
    else
      render :action => 'edit'
    end
  end

  # DELETE /programitems/1
  # DELETE /programitems/1.json
  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    programitem = Programitem.find(params[:id])
    program = programitem.program
    programitem.destroy
    expire_fragment('programs_xml')
    redirect_to :controller => 'programs', :action => 'edit', :id => program.id
  end
end
