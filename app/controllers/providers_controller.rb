class ProvidersController < ApplicationController
  before_filter :login_required

  def index
    @query_order = (params[:order].blank? ? 'name': params[:order])
    @direction = (params[:direction].blank? ? 'asc' : params[:direction])
    @filter = params[:filter]
    conditions = [' 1 = 1 ']
    unless @filter.blank?
      unless @filter[:name].blank?
        conditions[0] << ' AND providers.name LIKE ?'
        conditions << "%#{@filter[:name]}%"
      end
      unless @filter[:contact].blank?
        conditions[0] << ' AND providers.contact LIKE ? '
        conditions << "%#{@filter[:contact]}%"
      end
    end
    
    @providers = Provider.paginate(
      :page => params[:page],
      :per_page => 10,
      :conditions => conditions,
      :order => "#{@query_order} #{@direction}"
    )

  end

  def new
    @provider = Provider.new
  end

  def create
    @provider = Provider.new(params[:provider])
    if (@provider.save)
      redirect_to providers_url
    else
      render :action => :new
    end
  end

  def edit
    @provider = Provider.find(params[:id])
  end

  def update

    @provider = Provider.find(params[:id])
    @provider.update_attributes(params[:provider])

    if @provider.save
      redirect_to providers_url
    else
      render :action => :edit
    end
  end

  def destroy
    @provider = Provider.find(params[:id])
    if @provider.destroy
      redirect_to providers_url
    else
      # de momento va a la lista, que es donde se borran
      if (!@provider.errors.blank?)
        flash[:notice] = @provider.errors.full_messages.to_s
      else
        flash[:notice] = 'Provider could not be deleted!'
      end
      redirect_to providers_url
    end

  end

  def show
    @provider = Provider.find(params[:id])
  end

private

  def authorized?
    is_admin?
  end

  def access_denied
    if logged_in?
      redirect_to edit_user_url(current_user)
    else
      redirect_to root_url
    end
  end

end
