class GmController < Application
  before_filter :authorize, :except => [:index, :new, :create]
#  before_filter :authorize, :except => [:login]

  def index
    new
    render :action => 'new'
  end

  def new
    @person = Person.new
    @genre = nil
    @genres = AttributeValue.all(:conditions => "attribute_id in (select id from attributes where name='Genre') and visible = true",
                                :order => "sort")
    @genres.each { |genre|
      if genre.defaultvalue
        @genre = genre
      end
    }

    begin
      render(:layout => "layouts/" + @event.name.to_s + "_gm" )
    rescue Exception
      render
    end
  end

  def create
    gmgroup = Persongroup.first(:conditions => ["name='GM' and event_id=?", @event.id])
    @person = Person.find_by_primary_email(params[:person][:primary_email])
    if @person != nil
      if @person.firstname != params[:person][:firstname] && @person.lastname != params[:person][:lastname]
        flash[:notice] = 'Tällä sähköpostiosoitteella on jo henkilö kannassa!'
        redirect_to :action => 'new'
        return
      end
      @person.nickname = params[:person][:nickname]
      @person.primary_phone = params[:person][:primary_phone]
    else
      @person = Person.create(params[:person])
    end
    gmgroup.add( @person, Statusname.find_by_name( 'Toive' ) )

    if params[:shirt]
      tshirt = params[:shirt][:value]
      ts = Attribute.first(:conditions => "name='Staff-paita'")
      ts.add( @event, @person, tshirt, params[:shirttext] )
    end
    if params[:backroom]
      backroom = Attribute.first(:conditions => "name='Takahuone'")
      backroom.add( @event, @person, "Kyllä", "" )
    end
    num = 7
    if params[:game1][:name].length == 0
      flash[:notice] = 'Lomakkeella pitää ilmoittaa ainakin yksi peli!'
      redirect_to :action => 'new'
      return
    elsif params[:game2][:name].length == 0
      num = 1
    elsif params[:game3][:name].length == 0
      num = 2
    elsif params[:game4][:name].length == 0
      num = 3
    elsif params[:game5][:name].length == 0
      num = 4
    elsif params[:game6][:name].length == 0
      num = 5
    elsif params[:game7][:name].length == 0
      num = 6
    end
    @games = []
    g = Attribute.first(:conditions => "name='Genre'")
    genres = AttributeValue.all(:conditions => "attribute_id in (select id from attributes where name='Genre') and visible = true",
                                 :order => "sort")

    for i in 1..num
      gamesym = ("game" + i.to_s).to_sym
      game = Program.new
      game.name = params[gamesym][:name]
      game.attendance = params[gamesym][:attendance]
      game.description = params[gamesym][:description]
      game.publicnotes = params[gamesym][:system]
      game.event = @event
      game.privatenotes = "Ajankohta: " + params[gamesym][:preftime] + ", Kesto: " + params[gamesym][:duration] + ", " + params[gamesym][:privatenotes]
      game.status = -2
      game.save
      @games << game

      group = Programgroup.find(12)
      game.programgroups << group
      group.save

      genres.each { |genre|
        genresym = (genre.id.to_s).to_sym
        if params[gamesym][genresym]
          att = ProgramsEventsAttribute.new
          att.program = game
          att.event = @event
          att.attribute = g
          att[:value] = genre.value
          att.save
        end
      }
      @event.save
      g.save
      game.save

      if params[gamesym][:beginner]
        grp = Programgroup.find_by_name( "Aloittelijaystävällinen" )
        grp.programs << game
        grp.save
        game.save
      end
      if params[gamesym][:english]
        grp = Programgroup.find_by_name( "Englanninkielinen" )
        grp.programs << game
        grp.save
        game.save
      end
      if params[gamesym][:worldknowledge]
        grp = Programgroup.find_by_name( "Pelimaailman tuntemus suotavaa" )
        grp.programs << game
        grp.save
        game.save
      end
      if params[gamesym][:rulesknowledge]
        grp = Programgroup.find_by_name( "Pelisääntöjen tuntemus suotavaa" )
        grp.programs << game
        grp.save
        game.save
      end
      if params[gamesym][:adult]
        grp = Programgroup.find_by_name( "Ei sovellu lapsille" )
        grp.programs << game
        grp.save
        game.save
      end
      if params[gamesym][:children]
        grp = Programgroup.find_by_name( "Soveltuu lapsille" )
        grp.programs << game
        grp.save
        game.save
      end
      if params[gamesym][:loud]
        grp = Programgroup.find_by_name( "Äänekäs" )
        grp.programs << game
        grp.save
        game.save
      end

      organizer = ProgramsOrganizer.new
      organizer.person = @person
      organizer.program = game
      organizer.orgtype = 1
      organizer.save
      game.save
    end
    @person.save
    GmMailer.gmrequest("gm-info@ropecon.fi", @person.primary_email, nil, @event.name + " - GM-ilmoittautuminen / GM sign-up", @event, @person, @games).deliver
  end

  def list
    @gms = Person.find_by_sql(["select distinct people.* from people, persongroups, people_persongroups, events where people.id=people_persongroups.person_id and persongroups.id=people_persongroups.persongroup_id and persongroups.event_id=events.id and events.ispublic=true and persongroups.name='GM' and events.id=?", @event.id])
    @duplicates = {}
    for gm in @gms
      duplicate = Person.find_by_sql(["select distinct people.* from people where firstname = ? and lastname = ? and id != ?", gm.firstname, gm.lastname, gm.id])
      if duplicate != nil
        @duplicates[gm.id] = duplicate
      end
    end
  end

  def confirm
    program = Program.find(params[:id])
    program.status = -1
    program.save
    logger.info "Organizers is " + program.programs_organizers.to_json
    for organizer in program.programs_organizers
      for grp in organizer.person.people_persongroups
        if grp.persongroup.event.id == @event.id && grp.persongroup.name == 'GM'
          grp.status = -1
          grp.save
        end
      end
    end
    redirect_to :action => 'list'
  end

  def show
    @staff = Person.find(params[:id])
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    Program.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def yesno( game, grp )
    if game.programgroups.include?( grp )
      return "Kyllä / Yes"
    end
    return "Ei / No"
  end

end
