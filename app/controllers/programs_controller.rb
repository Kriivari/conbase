class ProgramsController < Application
  before_filter :authorize, :except => [:create, :public, :csv, :xml, :tabular]
#  caches_page :csv, :public, :tabular
#  cache_sweeper :program_sweeper, :only => [:edit, :create]

  def index
    @groups = Programgroup.all(:order => "name").map { |p| [p.name, p.id] }
    @locations = Location.all(:order => "name", :conditions => ["event_id=?", @event.id]).map { |p| [p.name, p.id] }
    @statuses = Statusname.all(:conditions => "program=true", :order => "name").map { |p| [p.name, p.id] }
  end

  def search
    @program = Program.new
  end

  def results
    term = "%" + params[:term].downcase + "%"
    @programs = Program.find_by_sql(["select distinct programs.* from programs where (lower(name) like ? or lower(description) like ?) and event_id=? order by name", term, term, @event.id])
    organizers = Program.find_by_sql(["select distinct programs.* from programs where id in (select program_id from programs_organizers where person_id in (select id from people where lower(firstname) like ? or lower(lastname) like ? or lower(nickname) like ?)) order by name", term, term, term])
    organizers.each { |p|
      unless @programs.include?( p )
        @programs << p
      end
    }
    items = Programitem.find_by_sql(["select distinct programitems.* from programitems where (lower(name) like ? or lower(description) like ?) and program_id in (select id from programs where event_id=?) order by program_id", term, term, @event_id])
    items.each { |item|
      unless @programs.include?( item.program )
        @programs << item.program
      end
    }

    render :action => "list"
  end

  def xml
    publicdata
    respond_to do |format|
      format.any do
        headers["Content-Type"] = "application/xml; charset=utf-8"
        render "xml.xml", :layout => false
      end
    end
  end

  def csv
    publicdata
    respond_to do |format|
      format.csv
    end
  end

  def public
    lang = "public"
    if params[:lang] != nil && params[:lang] == "en"
      lang = "publicen"
    end
    publicdata
    begin
      render(:action => lang, :layout => "layouts/" + @event.name.to_s + "_" + @event.year.to_s )
    rescue Exception
      render(:action => lang)
    end
  end

  def tabular
    publicdata
    render(:layout => "layouts/"+@event.name.to_s + "_" + @event.year.to_s+"_table")
  end

  def sort( programitems, type )
    if type == "loc"
      programitems.sort! { |x,y| [x.location, x.start_type] <=> [y.location, y.start_time] }
    elsif type == "type"
      programitems.sort! { |x,y| [x.location, x.start_type] <=> [y.location, y.start_time] }
    elsif type == "org"
      programitems.sort! { |x,y| [x.program.main_organizer.fullname, x.start_time, x.location] <=> [y.program.main_organizer.fullname, y.start_time, y.location] }
    else
      programitems.sort! { |x,y| [x.start_time, x.location] <=> [y.start_time, y.location] }
    end
  end

  def publicdata
    @groups = Programgroup.all(:order => "name")
    @wdays = %w(Su Ma Ti Ke To Pe La)
    wds = %w(xx ma ti ke to pe la su)
    if params[:id] != nil
      @event = Event.find(params[:id])
    end

    sort = "programitems.start_time, lname"
    if params[:sort] == "loc"
      sort = "lname, programitems.start_time"
    end
    if params[:sort] == "type"
      sort = "lname, programitems.start_time"
    end
    if params[:sort] == "org"
      sort = "people.lastname, people.firstname, programitems.start_time, lname"
    end

    starttime = @event.starttime
    endtime = @event.endtime
    if params[:time] && params[:time] != "" && params[:time] != "all"
      wday = wds.index( params[:time] )
      startwday = starttime.wday
      endwday = endtime.wday
      starttime = starttime + 24 * 3600 * ( wday - startwday )
      endtime = Time.local(starttime.year, starttime.month, starttime.mday, 23, 59)
      starttime = Time.local(starttime.year, starttime.month, starttime.mday, 0, 0)
    end

    @programs = nil
    if params[:lang] && params[:lang] == "en"
      @programs = Programitem.find_by_sql(["select programitems.*, locations.name as lname from programitems, locations where locations.id=programitems.location_id and ((programitems.start_time>? and programitems.start_time<?) or (programitems.end_time>? and programitems.end_time<?)) and programitems.program_id in (select id from programs where event_id=? and status=-1 and id in (select program_id from programs_programgroups where programgroup_id=10 or programgroup_id=14))", 
        starttime, endtime, starttime, endtime, @event.id])
      sort( @programs, params[:sort] )
    else
      if params[:group] != nil
        @group = params[:group]
        @programs = Programitem.find_by_sql(["select distinct programitems.*, locations.name as lname from programitems, locations, programs, programs_organizers, people where locations.id=programitems.location_id and ((programitems.start_time>? and programitems.start_time<?) or (programitems.end_time>? and programitems.end_time<?)) and programitems.program_id=programs.id and programs.event_id=? and programs.status=-1 and programs.id in (select program_id from programs_programgroups where programgroup_id=?) and programs.id=programs_organizers.program_id and programs_organizers.person_id=people.id",
          starttime, endtime, starttime, endtime, @event.id, params[:group]])
        sort( @programs, params[:sort] )
      else
        if params[:location] != nil
          @programs = Programitem.find_by_sql(["select programitems.*, locations.name as lname from programitems, locations where locations.id=programitems.location_id and ((programitems.start_time>? and programitems.start_time<?) or (programitems.end_time>? and programitems.end_time<?)) and programitems.location_id=? and programitems.program_id in (select id from programs where event_id=? and status=-1) order by " + sort, 
            starttime, endtime, starttime, endtime, params[:location], @event.id])
        else
          @programs = Programitem.find_by_sql(["select programitems.*, locations.name as lname from programitems, locations where locations.id=programitems.location_id and ((programitems.start_time>? and programitems.start_time<?) or (programitems.end_time>? and programitems.end_time<?)) and programitems.program_id in (select id from programs where event_id=? and status=-1) order by " + sort, 
            starttime, endtime, starttime, endtime, @event.id])
        end
      end
    end
  end

  def list
    @gm = Programgroup.first(:conditions => "id=12").id
    if params[:id] != nil
      @event = Event.find(params[:id])
    end
    if params[:filter] != nil || params[:grp] != nil
      @filter = nil
      if params[:filter]
        @filter = params[:filter]
      else
        @filter = params[:grp][:value]
      end
      @programs = Program.paginate :per_page => 500, :page => params[:page], :order => 'name', :conditions => ['event_id=? and id in (select program_id from programs_programgroups where programgroup_id=?)', @event.id, @filter]
    elsif params[:location] != nil || params[:loc] != nil
      @location = nil
      if params[:location]
        @location = params[:filter]
      else
        @location = params[:loc][:value]
      end
      @programs = Program.paginate :per_page => 500, :page => params[:page], :order => 'name', :conditions => ['id in (select program_id from programitems where location_id=?) and event_id=?', @location, @event.id]
    elsif params[:status] != nil
      @status = params[:status][:value]
      @programs = Program.paginate :per_page => 500, :page => params[:page], :order => 'name', :conditions => ['status=? and event_id=?', @status, @event.id]
    else
      @programs = Program.paginate :per_page => 500, :page => params[:page], :order => 'name', :conditions => ['event_id=? and id not in (select program_id from programs_programgroups where programgroup_id=?)', @event.id, @gm]
    end
  end

  def sanitycheck
    @programs = Program.paginate :page => params[:page], :order => 'name', :conditions => ['event_id=? and id not in (select program_id from programitems where location_id is not null)', @event.id]
  end

  # GET /programs/1
  # GET /programs/1.pdf
  def show
    @program = Program.find(params[:id])
    for lang in @program.program_languages
      if lang.language == "en"
        @englishname = lang.name
        @englishdescription = lang.description
      end
    end
    respond_to do |format|
      format.html
      format.pdf { render :layout => false }
    end
  end

  def new
    @program = Program.new
    @person = Person.new
    @type = nil
    @types = Programgroup.where('visible is true').map { |p| [p.name, p.id] }
    if verify
      @people = Person.all(:order => "lastname, firstname")
    else
      render(:layout => "Ropecon_program_registration")
    end
  end

  def newlarp
    new
  end

  def create
    if params[:person][:firstname] == nil || params[:person][:firstname].length == 0
      @person = Person.find(params[:organizers][:id])
    end
    if @person == nil
      @person = Person.find_by_primary_email(params[:person][:primary_email])
      if @person != nil
        @person.primary_phone = params[:person][:primary_phone]
        @person.birthyear = params[:person][:birthyear]
        @person.save
      else
        if params[:person][:firstname] != nil && params[:person][:firstname] != ""
          @person = Person.create(params[:person])
          if params[:person][:primary_email] == nil || params[:person][:primary_email] == ""
            @person.primary_email = @person.firstname + @person.lastname + "@" + (rand*10000).to_i.to_s + "example.com"
          end
          if params[:person][:primary_phone] == nil || params[:person][:primary_phone] == ""
            @person.primary_phone = "ei tiedossa"
          end
          @person.save
        end
      end
    end

    wishstatus = Statusname.find_by_name("Toive")
    persongroup = Persongroup.first(:conditions => ["name=? and event_id=?", "Ohjelma", @event.id])
    if @person != nil
      persongroup.add( @person, wishstatus )
    end

    @program = Program.new(params[:program])
    @program.event = @event
    @program.statusname = wishstatus

    english = ProgramLanguage.new
    english.language = "en"
    if params[:english] != nil
      english.name = params[:english][:name]
      english.description = params[:english][:description]
    else
      english.name = ''
      english.description = ''
    end
    @program.program_languages << english

    if @person != nil
      organizer = ProgramsOrganizer.new
      organizer.person = @person
      organizer.program = @program
      organizer.orgtype = -6
      organizer.save
    end

    if params[:groups] != nil 
      for t in params[:groups].keys
        group = Programgroup.find(t)
        @program.programgroups << group
        group.save
      end
    end

    if params[:larp]
      save_larp( params[:larp], @program )
    end

    expire_fragment('programs_xml')
    if @program.save && english.save
      flash[:notice] = 'Program was successfully created.'
      if params[:organizers] != nil
        redirect_to :action => 'list'
      end
    else
      @type = nil
      @types = Programgroup.all.map { |p| [p.name, p.id] }
      render :action => 'new'
    end

    if !verify
      render(:layout => "Ropecon_program_registration")
    end
  end

  def save_larp( params, program )
    larpgroup = Programgroup.find_by_name("Larpit")
    program.programgroups << larpgroup
    larpgroup.save
    if params[:beginner] == "yes"
      beginnergroup = Programgroup.find_by_name("Aloittelijaystävällinen")
      program.programgroups << beginnergroup
      beginnergroup.save
    end
    if params[:english] == "yes"
      englishgroup = Programgroup.find_by_name("Englanninkielinen")
      program.programgroups << englishgroup
      englishgroup.save
    end
    program.attendance = params[:players]
    signupsheet = "LARP-tiski"
    if params[:signupsheet] == "self"
      signupsheet = "Järjestäjä itse"
    end
    program.privatenotes = "Mieshahmot: " + params[:male] + "\nNaishahmot: " + params[:female] + "\nNeutraalit: " + params[:neutral] + "\nVähimmäismäärä: " + params[:minimum] + "\nIlmolomakkeen tekee: " + signupsheet + "\nTilatoiveet: " + params[:location] + "\nPelin pituus: " + params[:length] + "\nAikataulutoiveet: " + params[:scheduling] + "\nTarvikkeet: " + params[:props] + "\nMuita tietoja: " + program.privatenotes
  end

  def edit
    @groups = Programgroup.all.map { |p| [p.name, p.id] }
    @groups = [['Ei uutta ryhmää', 0]] + @groups
    @attributes = Attribute.all(:conditions => "program=true", :order => "name").map { |p| [p.name, p.id] }
    @attributes = [['Ei uutta attribuuttia', 0]] + @attributes
    @program = Program.find(params[:id])
    @statuses = Statusname.all(:conditions => "program=true", :order => "name")
    @organizerstatuses = Statusname.all(:conditions => "organizer=true", :order => "name")
    @people = Person.all(:order => "lastname, firstname")
    dummy = Person.new
    dummy.id = -999999
    dummy.lastname = 'Valitse'
    dummy.firstname = 'listasta'
    @people = [dummy] + @people
    for lang in @program.program_languages
      if lang.language == "en"
        @englishname = lang.name
        @englishdescription = lang.description
      end
    end
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    expire_fragment('programs_xml')

    @program = Program.find(params[:id])
    if params[:commit].index("Lis") == 0
      if params[:organizers][:id] == "-999999" && ! params[:person][:firstname]
	      flash[:notice] = "Et valinnut nimeä!"
        redirect_to :action => 'edit', :id => @program
	      return
      end
      organizer = ProgramsOrganizer.new
      if params[:person] && params[:person][:firstname] && params[:person][:firstname].length > 0
        if Person.find_by_primary_email(params[:person][:primary_email])
          flash[:duplicate] = "Tällä sähköpostiosoitteella on jo henkilö tietokannassa."
          redirect_to :action => 'edit', :id => @program
          return
        end
        person = Person.create(params[:person])
      else
        person = Person.find(params[:organizers][:id])
      end
      organizer.person = person
      organizer.program = @program
      organizer.orgtype = params[:organizers][:status]
      organizer.save
      person.save
      @program.save
      redirect_to :action => 'edit', :id => @program
    else
      language = nil
      for lang in @program.program_languages
        if lang.language == "en"
          language = lang
        end
      end
      if language == nil
        language = ProgramLanguage.new
        language.language = "en"
        @program.program_languages << language
      end
      language.name = params[:english][:name]
      language.description = params[:english][:description]
      language.save
      
      if params[:grp][:value] != '0'
        group = Programgroup.find(params[:grp][:value])
        unless @program.programgroups.include?( group )
          @program.programgroups << group
          group.save
          @program.save
        end
      end

      if params[:att][:id] != '0'
        att = Attribute.find(params[:att][:id])
        a = ProgramsEventsAttribute.new
        a.program = @program
        a.attribute = att
        a.event = @event
        a[:value] = params[:att][:value]
        a.save
        @program.save
      end

      if params[:program][:status] == "-1"
        for organizer in @program.programs_organizers
          for persongroup in organizer.person.people_persongroups
            if persongroup.persongroup.name == "Ohjelma" && persongroup.persongroup.event.id == @event.id
              persongroup.status = -1
              persongroup.save
              organizer.person.save
            end
          end
        end
      end

      if @program.update_attributes(params[:program])
        flash[:notice] = 'Program was successfully updated.'
        redirect_to :action => 'show', :id => @program
      else
        render :action => 'edit'
      end
    end
  end

  def rmgroup
    if ! canedit
      redirect_to :action => 'list'
    end
    group = Programgroup.find(params[:groupid])
    program = Program.find(params[:programid])
    program.programgroups.delete(group)
    expire_fragment('programs_xml')
    redirect_to :action => 'show', :id => params[:programid]
  end

  def rmattribute
    if ! canedit
      redirect_to :action => 'list'
    end
    att = ProgramsEventsAttribute.find(params[:attributeid])
    att.destroy
    expire_fragment('programs_xml')
    redirect_to :action => 'show', :id => params[:programid]
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    program = Program.find(params[:id])
    program.program_languages.each { |l| l.destroy }
    program.destroy
    expire_fragment('programs_xml')
    redirect_to :action => 'list'
  end

  def remove_organizer
    if ! canedit
      redirect_to :action => 'list'
    end
    organizer = ProgramsOrganizer.find(params[:id])
    @program = Program.find(params[:program])
    organizer.destroy
    @program.save
    expire_fragment('programs_xml')
    redirect_to :action => 'list'
  end
end
