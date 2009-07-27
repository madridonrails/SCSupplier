class AssembliesController < ApplicationController
  before_filter :login_required
  before_filter :find_product

  def index
    @assemblies = @product.assemblies
  end

  def new
    @assembly = Assembly.new
  end

  def edit
    @assembly = @product.assemblies.find(params[:id])
  end

  def create
    @assembly = Assembly.new(params[:assembly])
    if (@product.assemblies << @assembly)
      redirect_to product_assemblies_url(@product)
    else
      # si, lo sé, antes redirigía new que no hay. lo dejo por claridad
      redirect_to product_assemblies_url(@product)
    end
  end

  def update
    @assembly = @product.assemblies.find(params[:id])
    if @assembly.update_attributes(params[:assembly])
      redirect_to product_url(@product)
    else
      render :action => :edit
    end
  end

  def destroy
    @assembly = Assembly.find(params[:id])
    if @assembly.delete
      redirect_to product_assemblies_url
    end
  end

  def show
    @assembly = Assembly.find(params[:id])
  end

private

  def find_product
    @product_id = params[:product_id]
    return(redirect_to products_url) if @product_id.blank?
    @product = Product.find(@product_id)
  end

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
