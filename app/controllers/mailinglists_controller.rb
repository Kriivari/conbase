class MailinglistsController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @mailinglists = Mailinglist.paginate :page => params[:page]
  end

  def show
    @mailinglist = Mailinglist.find(params[:id])
  end

  def new
    @mailinglist = Mailinglist.new
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    @mailinglist = Mailinglist.new(params[:mailinglist])
    if @mailinglist.save
      flash[:notice] = 'Mailinglist was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @mailinglist = Mailinglist.find(params[:id])
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @mailinglist = Mailinglist.find(params[:id])
    if @mailinglist.update_attributes(params[:mailinglist])
      flash[:notice] = 'Mailinglist was successfully updated.'
      redirect_to :action => 'show', :id => @mailinglist
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    Mailinglist.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
