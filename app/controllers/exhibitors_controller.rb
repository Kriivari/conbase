class ExhibitorsController < Application
  before_filter :authorize, :except => [:new, :create]

  def index
    list
    render :action => 'list'
  end

  def list
    @exhibitors = Exhibitor.all(:conditions => "event_id=" + @event.id.to_s, :order => "companyname")
    if params[:full]
      @fulllist = 1
    end
  end

  def show
    @exhibitor = Exhibitor.find(params[:id])
  end

  def invoice
    @exhibitor = Exhibitor.find(params[:id])
    unless @exhibitor.invoicedate
      @exhibitor.invoicedate = Time.now
      @exhibitor.save
    end
    unless @exhibitor.duedate
      @exhibitor.duedate = Time.now + 14 * 24 * 3600
      @exhibitor.save
    end
    respond_to do |format|
      format.html
      format.pdf do
        pdf = InvoicePdf.new( @exhibitor )
        send_data pdf.render
      end
    end
  end

  def new
    @exhibitor = Exhibitor.new
    @sizes = ProductType.where( :active => true ).includes( :products ).where( :name => "Myyntipöytä" )
#    @sizes = Product.find_by_name( "Myyntipöytä" ).product_types.active( true )
  end

  def create
    @exhibitor = Exhibitor.create(params[:exhibitor])
    unless params[:agree]
      @exhibitor.errors.add(:companyname, "Et sitoutunut Kaubamajan ehtoihin.")
      render
      return
    end
    person = Person.find_by_primary_email(params[:person][:primary_email])
    unless person
      person = Person.create(params[:person])
    end
    @exhibitor.person = person

    table = ProductType.find_by_name(params[:table])
    ticket = ProductType.find_by_name("Viikonloppu")
    travelpass = ProductType.find_by_name("Myyjäpassi")

    for i in 1..params[:tables].to_i
      @exhibitor.product_types << table
    end
    for i in 1..params[:tickets].to_i
      @exhibitor.product_types << ticket
    end
    for i in 1..params[:travelpasses].to_i
      @exhibitor.product_types << travelpass
    end

    @exhibitor.notes = @exhibitor.notes + "\n\nMainostiedot:\n" + params[:advertisements]
    @exhibitor.event = @event
    person.save
    @event.save
    @exhibitor.save
    ExhibitorMailer.confirmation_email(@event,@exhibitor).deliver
  end

  def destroy
    Exhibitor.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  def edit
    @exhibitor = Exhibitor.find(params[:id])
    @product_types = ProductType.all(:conditions => "active=true", :order => "product_id,name").map { |g| [g.fullname, g.id] }
    @product_types = [['Ei uutta tuotetta', 0]] + @product_types
  end

  def update
    @exhibitor = Exhibitor.find(params[:id])

    if params[:product][:type] != '0'
      product = ProductType.find(params[:product][:type])
      @exhibitor.product_types << product
    end

    if @exhibitor.update_attributes(params[:exhibitor])
      flash[:notice] = 'Kaubamajavaraus päivitetty.'
      redirect_to :action => 'show', :id => @exhibitor
    else
      render :action => 'edit'
    end
  end

  def rmproduct
    exhibitor = Exhibitor.find( params[:exhibitor_id] )
    product = ProductType.find( params[:product_id] )
    exhibitor.product_types.delete( product )
    exhibitor.save
    redirect_to :action => 'edit', :id => exhibitor.id
  end

end
