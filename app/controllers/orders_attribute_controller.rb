class OrdersAttributeController < Application
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @order_pages, @orders = paginate :orders, :per_page => 10
  end

  def show
    @order = Order.find(params[:id])
  end

  def new
    @order = Order.new
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = 'Order was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      flash[:notice] = 'Order was successfully updated.'
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
end
