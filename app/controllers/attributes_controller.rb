class AttributesController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @attributes = Attribute.paginate :page => params[:page]
  end

  def show
    @attribute = Attribute.find(params[:id])
  end

  def new
    @attribute = Attribute.new
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    @attribute = Attribute.new(params[:attribute])
    if @attribute.save
      flash[:notice] = 'Attribute was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @attribute = Attribute.find(params[:id])
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @attribute = Attribute.find(params[:id])
    if @attribute.update_attributes(params[:attribute])
      flash[:notice] = 'Attribute was successfully updated.'
      redirect_to :action => 'show', :id => @attribute
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    Attribute.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
