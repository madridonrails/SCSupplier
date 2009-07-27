class ClientsController < ApplicationController

  before_filter :login_required
  def index
    @query_order = (params[:order].blank? ? 'name': params[:order])
    @direction = (params[:direction].blank? ? 'asc' : params[:direction])
    @filter = params[:filter]
    conditions = [' 1 = 1 ']
    unless @filter.blank?
      unless @filter[:client_name].blank?
        conditions[0] << ' AND clients.client_name LIKE ?'
        conditions << "%#{@filter[:client_name]}%"
      end
      unless @filter[:name].blank?
        conditions[0] << ' AND clients.name LIKE ?'
        conditions << "%#{@filter[:name]}%"
      end
    end
    
    @clients = Client.paginate(
      :page => params[:page],
      :per_page => 10,
      :conditions => conditions,
      :order => "#{@query_order} #{@direction}"
    )

  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])
    if (@client.save)
      redirect_to clients_url
    else
      render :action => :new
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update

    @client = Client.find(params[:id])
    @client.update_attributes(params[:client])

    if @client.save
      redirect_to clients_url
    else
      render :action => :edit
    end
  end

  def destroy
    @client = Client.find(params[:id])
    if @client.destroy
      redirect_to clients_url
    else
      # de momento va a la lista, que es donde se borran
      if (!@client.errors.blank?)
        flash[:notice] = @client.errors.full_messages.to_s
      else
        flash[:notice] = 'Client could not be deleted!'
      end
      redirect_to clients_url
    end

  end

  def show
    @client = Client.find(params[:id])
  end

private

  def authorized?
    is_admin? || is_sales?
  end

  def access_denied
    if logged_in?
      redirect_to edit_user_url(current_user)
    else
      redirect_to root_url
    end
  end
end
