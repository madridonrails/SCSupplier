class RawProductsController < ApplicationController

  before_filter :login_required
  before_filter :find_raw_product, :only => [:show, :edit, :update, :destroy]

  def find_raw_product
    @raw_product = RawProduct.find(params[:id])
  end


  def index
   @filter = params[:filter]
   conditions = [ '1 = 1']
   @query_order = params[:order].blank? ? "raw_products.name" : params[:order]
   @direction = params[:direction].blank? ? "asc" : params[:direction]
   unless @filter.blank?

      if (!@filter[:provider].blank?)
        conditions[0] << ' AND raw_products.provider_id = ?'
        conditions << @filter[:provider].gsub("/", "")
      end

      if !@filter[:name].blank?
        if !@filter[:description].blank?
          conditions[0] << ' AND ( raw_products.name LIKE ?'
          conditions << "%#{@filter[:name]}%"
          conditions[0] << ' OR raw_products.description LIKE ? )'
          conditions << "%#{@filter[:description]}% "
        else
          conditions[0] << ' AND raw_products.name LIKE ?'
          conditions << "%#{@filter[:name]}%"
        end
      else
        if !@filter[:description].blank?
        conditions[0] << ' AND raw_products.description LIKE ?'
        conditions << "%#{@filter[:description]}%"
       end
      end
    end

   @raw_products = RawProduct.paginate(
      :per_page => 10,
      :page => params[:page],
      :conditions => conditions,
      :order => "#{@query_order} #{@direction}"
    )
  end

  def edit
    @raw_product = RawProduct.find(params[:id])
  end

  def show
  end

  def new
    @raw_product = RawProduct.new
    @raw_product.stock = 0
  end

  def create

    @raw_product = RawProduct.new(params[:raw_product])
    if (@raw_product.save)
      flash[:notice] = 'Raw Product was successfully created.'
      #redirect_to(@raw_product)
      redirect_to raw_products_url
    else
      render :action => "new"
    end
  end

  def update
    if @raw_product.update_attributes(params[:raw_product])
      flash[:notice] = 'Raw Product was successfully updated.'
      #redirect_to(@raw_product)
      redirect_to raw_products_url
    else
      render :action => "edit"
    end
  end

  def destroy
    @raw_product = RawProduct.find(params[:id])
    if @raw_product.destroy
      redirect_to(raw_products_url)
    else
      # de momento va a la lista, que es donde se borran
      if (!@raw_product.errors.blank?)
        flash[:notice] = @raw_product.errors.full_messages.to_s
      else
        flash[:notice] = 'Base Product could not be deleted!'
      end
      redirect_to(raw_products_url)
    end
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
