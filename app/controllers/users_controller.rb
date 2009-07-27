class UsersController < ApplicationController
  before_filter :login_required
  
  def index
    @query_order = (params[:order].blank? ? 'login': params[:order])
    @direction = (params[:direction].blank? ? 'asc' : params[:direction])
    @filter = params[:filter]
    conditions = [' 1 = 1 ']
    unless @filter.blank?
      unless @filter[:login].blank?
        conditions[0] << ' AND users.login LIKE ?'
        conditions << "%#{@filter[:login]}%"
      end
      unless @filter[:email].blank?
        conditions[0] << ' AND users.email LIKE ? '
        conditions << "%#{@filter[:email]}%"
      end
    end
    
    @users = User.paginate(
      :page => params[:page],
      :per_page => 10,
      :conditions => conditions,
      :order => "#{@query_order} #{@direction}"
    )
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.locale_id = params[:user][:locale_id].to_i
    @user.is_admin = params[:user][:is_admin].to_i
    @user.is_sales = params[:user][:is_sales].to_i
    @user.is_stock = params[:user][:is_stock].to_i
    if @user.save(true)
      redirect_to users_url
    else
      render :action => :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    @user.locale_id = params[:user][:locale_id].to_i
    if is_admin?
      @user.is_admin = params[:user][:is_admin].to_i
      @user.is_sales = params[:user][:is_sales].to_i
      @user.is_stock = params[:user][:is_stock].to_i
    end

    if @user.save
      redirect_to users_url
    else
      render :action => :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to users_url
    else
      # de momento va a la lista, que es donde se borran
      if (!@user.errors.blank?)
        flash[:notice] = @user.errors.full_messages.to_s
      else
        flash[:notice] = 'User could not be deleted!'
      end
      redirect_to users_url
    end

  end

  def show
    @user = User.find(params[:id])
  end
  
  private
  def authorized?
    is_admin? || (logged_in? && params[:id].to_i == current_user.id && ['edit', 'update'].index(params[:action]))
  end
  
  def access_denied
    if logged_in?
      redirect_to edit_user_url(current_user)
    else
      redirect_to root_url
    end
  end
end
