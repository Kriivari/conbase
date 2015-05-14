class AttributeValuesController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @attribute_values = AttributeValue.paginate :page => params[:page]
  end

  def show
    @attribute_value = AttributeValue.find(params[:id])
  end

  def new
    @attribute_value = AttributeValue.new
    @attributes = Attribute.all(:order => "name").map {|a| [a.name,a.id]}
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    @attribute_value = AttributeValue.new
    @attribute_value.value = params[:attribute_value][:value]
    @attribute_value.defaultvalue = params[:attribute_value][:defaultvalue]
    attribute = Attribute.find(params[:attribute][:attribute])
    @attribute_value.attribute = attribute
    if @attribute_value.save
      flash[:notice] = 'AttributeValue was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @attribute_value = AttributeValue.find(params[:id])
    @attributes = Attribute.all(:order => "name").map {|a| [a.name,a.id]}
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @attribute_value = AttributeValue.find(params[:id])
    @attribute_value.value = params[:attribute_value][:value]
    @attribute_value.defaultvalue = params[:attribute_value][:defaultvalue]
    attribute = Attribute.find(params[:attribute][:attribute])
    @attribute_value.attribute = attribute
    if @attribute_value.save
      flash[:notice] = 'AttributeValue was successfully updated.'
      redirect_to :action => 'show', :id => @attribute_value
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    AttributeValue.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
