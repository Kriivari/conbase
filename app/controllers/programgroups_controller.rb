class ProgramgroupsController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  def list
    @programgroups = Programgroup.paginate :page => params[:page]
  end

  def show
    @programgroup = Programgroup.find(params[:id])
  end

  def new
    @programgroup = Programgroup.new
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    @programgroup = Programgroup.new(params[:programgroup])
    if @programgroup.save
      flash[:notice] = 'Programgroup was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @programgroup = Programgroup.find(params[:id])
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @programgroup = Programgroup.find(params[:id])
    if @programgroup.update_attributes(params[:programgroup])
      flash[:notice] = 'Programgroup was successfully updated.'
      redirect_to :action => 'show', :id => @programgroup
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    Programgroup.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
end
