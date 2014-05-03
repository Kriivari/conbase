class OrderitemsController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @orderitem_pages, @orderitems = paginate :orderitems, :per_page => 10
  end

  def show
    @orderitem = Orderitem.find(params[:id])
  end

  def new
    @orderitem = Orderitem.new
  end

  def create
    @orderitem = Orderitem.new(params[:orderitem])
    if @orderitem.save
      flash[:notice] = 'Orderitem was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @orderitem = Orderitem.find(params[:id])
  end

  def update
    @orderitem = Orderitem.find(params[:id])
    if @orderitem.update_attributes(params[:orderitem])
      flash[:notice] = 'Orderitem was successfully updated.'
      redirect_to :action => 'show', :id => @orderitem
    else
      render :action => 'edit'
    end
  end

  def destroy
    Orderitem.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
