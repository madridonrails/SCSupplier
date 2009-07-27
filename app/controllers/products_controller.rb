class ProductsController < ApplicationController

  before_filter :login_required

  def index
    @query_order = (params[:order].blank? ? 'reference': params[:order])
    @direction = (params[:direction].blank? ? 'asc' : params[:direction])
    @filter = params[:filter]
    conditions = [' 1 = 1 ']
    unless @filter.blank?
      unless @filter[:name].blank?
        conditions[0] << ' AND products.name LIKE ?'
        conditions << "%#{@filter[:name]}%"
      end
      unless @filter[:reference].blank?
        conditions[0] << ' AND products.reference LIKE ?'
        conditions << "%#{@filter[:reference]}%"
      end
      unless @filter[:description].blank?
        conditions[0] << ' AND products.description LIKE ?'
        conditions << "%#{@filter[:description]}%"
      end
    end
    
    @products = Product.paginate(
      :page => params[:page],
      :per_page => 10,
      :conditions => conditions,
      :order => "#{@query_order} #{@direction}"
    )

  end

  def new
    @product = Product.new
    @product.stock = 0
  end

  def create
    @product = Product.new(params[:product])
    if (@product.save)
      redirect_to product_assemblies_url(@product)
    else
      render :action => :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update

    @product = Product.find(params[:id])
    @product.update_attributes(params[:product])

    if @product.save
      redirect_to products_url
    else
      render :action => :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    if @product.destroy
      redirect_to products_url
    else
      # de momento va a la lista, que es donde se borran
      if (!@product.errors.blank?)
        flash[:notice] = @product.errors.full_messages.to_s
      else
        flash[:notice] = 'Product could not be deleted!'
      end
      redirect_to products_url
    end

  end

  def show
    @product = Product.find(params[:id])
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
