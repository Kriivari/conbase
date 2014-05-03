class PersoneventattributesController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  def list
    @personeventattributes = Personeventattribute.paginate :page => params[:page]
  end

  def show
    @personeventattribute = Personeventattribute.find(params[:id])
  end

  def new
    @personeventattribute = Personeventattribute.new
  end

  def create
    @personeventattribute = Personeventattribute.new(params[:personeventattribute])
    if @personeventattribute.save
      flash[:notice] = 'Personeventattribute was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @personeventattribute = Personeventattribute.find(params[:id])
  end

  def update
    @personeventattribute = Personeventattribute.find(params[:id])
    if @personeventattribute.update_attributes(params[:personeventattribute])
      flash[:notice] = 'Personeventattribute was successfully updated.'
      redirect_to :action => 'show', :id => @personeventattribute
    else
      render :action => 'edit'
    end
  end

  def destroy
    Personeventattribute.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
