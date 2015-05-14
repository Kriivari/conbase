class PurchasesController < Application
  before_filter :authorize

  # GET /purchases
  # GET /purchases.json
  def index
    @purchases = Purchase.all(:conditions => ["event_id=?", @event.id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @purchases }
    end
  end

  # GET /purchases/1
  # GET /purchases/1.json
  def show
    @purchase = Purchase.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @purchase }
    end
  end

  # GET /purchases/new
  # GET /purchases/new.json
  def new
    @purchase = Purchase.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @purchase }
    end
  end

  # GET /purchases/1/edit
  def edit
    @purchase = Purchase.find(params[:id])
  end

  # POST /purchases
  # POST /purchases.json
  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    @purchase = Purchase.new(params[:purchase])
    @person = Person.find(params[:purchase][:person_id])
    @producttype = ProductType.find(params[:product_item_purchase][:product_item_id])
    @purchase.event = @event
    @purchase.person = @person
    @purchase.product_types << @producttype

    respond_to do |format|
      if @purchase.save
        @producttype.save
        format.html { redirect_to @purchase, :notice => 'Purchase was successfully created.' }
        format.json { render :json => @purchase, :status => :created, :location => @purchase }
      else
        format.html { render :action => "new" }
        format.json { render :json => @purchase.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /purchases/1
  # PUT /purchases/1.json
  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @purchase = Purchase.find(params[:id])
    @person = Person.find(params[:purchase][:person_id])
    @producttype = ProductType.find(params[:product_item_purchase][:product_item_id])
    @purchase.event = @event
    @purchase.person = @person
    @purchase.product_types.clear
    @purchase.product_types << @producttype

    respond_to do |format|
      if @purchase.update_attributes(params[:purchase])
        @producttype.save
        format.html { redirect_to @purchase, :notice => 'Purchase was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @purchase.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /purchases/1
  # DELETE /purchases/1.json
  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    @purchase = Purchase.find(params[:id])
    @purchase.destroy

    respond_to do |format|
      format.html { redirect_to purchases_url }
      format.json { head :no_content }
    end
  end

  # GET /purchases/lipputilaus
  # GET /purchases/lipputilaus.json
  def lipputilaus
    @person = Person.new
    @tickettypes = ProductType.all(:conditions => ["product_id=?", Product.first(:conditions => ["name='Ranneke'"]).id])
    begin
      render(:layout => "layouts/" + @event.name.to_s + "_staff" )
    rescue Exception
      render
    end
  end

  # POST /purchases/order
  # POST /purchases/order.json
  def order
    @event = Event.find_by_id(params[:event])
    @person = Person.find_by_primary_email(params[:person][:primary_email])
    if @person == nil
      @person = Person.new(params[:person])
      @person.save
    end
    @tickettype = ProductType.find(params[:product][:id])
    @ticketcount = params[:ticketcount]
    @purchase = Purchase.new
    @purchase.event = @event
    @purchase.person = @person
    for i in 1..@ticketcount.to_i
      @purchase.product_type << @tickettype
    end
    @purchase.save
    baseprice = @ticketcount.to_i * @tickettype.price.to_i
    basename = @tickettype.fullname
    realbody = @event.ticketfooter
    realbody = realbody.gsub("%PRICE%",baseprice.to_s.sub(".",","))
    realbody = realbody.gsub("%REFERENCE%",@purchase.reference)
    realbody = realbody.gsub("%SHIRTDETAILS%", basename)
    GenericMailer.email(@event, "kaubamaja@ropecon.fi", @person.primary_email, "ranneketilauksen maksuohjeet", realbody).deliver

    begin
      render(:layout => "layouts/" + @event.name.to_s + "_staff" )
    rescue Exception
      render
    end
  end
end
