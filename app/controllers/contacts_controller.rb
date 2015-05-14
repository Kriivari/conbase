class ContactsController < Application
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @contacts = Contact.paginate :page => params[:page]
  end

  def show
    @contact = Contact.find(params[:id])
  end

  def new
    @contact = Contact.new
  end

  def create
    if ! canedit
      redirect_to :action => 'list'
    end
    @contact = Contact.new(params[:contact])
    if @contact.save
      flash[:notice] = 'Contact was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    if ! canedit
      redirect_to :action => 'list'
    end
    @contact = Contact.find(params[:id])
    if @contact.update_attributes(params[:contact])
      flash[:notice] = 'Contact was successfully updated.'
      redirect_to :action => 'show', :id => @contact
    else
      render :action => 'edit'
    end
  end

  def destroy
    if ! canedit
      redirect_to :action => 'list'
    end
    Contact.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
