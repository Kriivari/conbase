class ProgramviewController < Application
  def index
    list
    render :action => 'list'
  end

  def list
    name = params[:name]
    year = params[:year]
    if name != nil && year != nil
      @event = Event.first(:conditions => ["name=? and year=?", name, year])
    end
    if params[:start] != nil
      @starttime = Time.parse( params[:start] )
    else
      @starttime = @event.starttime
    end
    if params[:end] != nil
      @endtime = Time.parse( params[:end] )
    else
      @endtime = @event.endtime
    end
    @programs = Program.all(:conditions => ["id in (select program_id from programitems where start_time between ? and ?) and event_id=?", @starttime, @endtime, event.id])
  end
end
