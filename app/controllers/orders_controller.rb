class OrdersController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [:destroy, :create, :update],
  #       :redirect_to => {:action => :list}

  def list
    if params[:event]
      event = Event.find(params[:event])
    else
      event = @event
    end
    @orders = Order.all(:conditions => "status != -8 and event_id=" + event.id.to_s, :order => "id")
  end

  def itemlist
    @order = Order.new
    @items = []
    items = Orderitem.all
    for item in items
      if item.order != nil && item.order.event != nil && item.order.event == @event && item.order.status != -8
        if params[:all] || item.status != 1
          @items << item
        end
      end
    end
    if params[:sort]
      @items.sort! { |a, b| a.send(params[:sort]) <=> b.send(params[:sort]) }
    end
    @statuses = Statusname.all(:conditions => "orders=true", :order => "name")
  end

  def saveitems
    if ! canedit
      redirect_to :action => 'list'
    end
    status = params[:order][:status]
    for checked in params[:checked].keys
      orderitem = Orderitem.find(checked)
      orderitem.status = status
      orderitem.save
      orderitem.order.change_status
      orderitem.save
    end

    redirect_to :action => 'itemlist'
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
    @order.needed = @event.starttime
    @order.released = @event.endtime
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    toive = Statusname.first(:conditions => "name='Toive'")

    @order = Order.new(params[:order])
    @order.event = @event
    @order.person = @user
    @order.statusname = toive

    for i in 1..25
      item = Orderitem.new(params[("orderitem" + i.to_s).to_sym])
      if item.name != nil && item.name.length > 0
        item.statusname = toive
        @order.orderitems << item
        item.save
      end
    end

    if @order.save
      flash[:notice] = 'Tilaus luotu.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @order = Order.find(params[:id])
    if @order.event != @event
      toive = Statusname.first(:conditions => "name='Toive'")
      oldorder = @order
      @order = Order.new( oldorder.attributes )
      @order.event = @event
      @order.person = @user
      @order.statusname = toive
      @order.orderitems.clear
      for item in oldorder.orderitems
        i = Orderitem.new( item.attributes )
        i.statusname = toive
        @order.orderitems << i

      end
      @order.save
    end
    @statuses = Statusname.all(:conditions => "orders=true", :order => "name")
    @attributes = Attribute.all(:conditions => "orders=true")
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @order = Order.find(params[:id])
    @order.orderitems.clear
    @order.name = params[:name]
    @order.destination = params[:destination]
    @order.notes = params[:notes]
    @order.needed = params[:needed]
    @order.released = params[:released]
    @order.commentlog = params[:commentlog]

    for i in 1..25
      item = Orderitem.new(params[("orderitem" + i.to_s).to_sym])
      if item.name != nil && item.name.length > 0
        @order.orderitems << item
        item.save
      end
    end

    @attributes = Attribute.all(:conditions => "orders=true")
    for attribute in @attributes
      attsym = ("att" + attribute.id.to_s).to_sym
      if params[attsym][:value] != '0'
        value = AttributeValue.find(params[attsym][:value]).value
        attribute.add_order(@order, value, params[attsym][:notes])
      end
    end

    if @order.status != params[:status]
      @order.status = params[:status]
      for item in @order.orderitems
        item.status = @order.status
      end
    end
    @order.save

    if @order.update_attributes(params[:order])
      flash[:notice] = 'Tilaus päivitetty.'
      redirect_to :action => 'show', :id => @order
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    Order.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def rmattribute
    if ! canedit
      redirect_to :action => 'list'
    end
    att = OrdersAttribute.find(params[:id])
    order = att.order
    att.destroy
    redirect_to :action => 'edit', :id => order.id
  end

  def confirmed(body)
    if ! canedit
      redirect_to :action => 'list'
    end
    status = Statusname.find(params[:admin][:status])
    for checked in params[:checked].keys
      item = Orderitem.find(checked)
      item.status = status
      item.save
    end
    redirect_to :action => 'itemlist'
  end
end
