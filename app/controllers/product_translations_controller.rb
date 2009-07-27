class ProductTranslationsController < ApplicationController
  before_filter :login_required
  before_filter :get_product

  def index
    @product_translations = @product.product_translations
  end
  
  def new
    @product_translation = @product.product_translations.new
  end

  def create
    @product.product_translations.create(params[:product_translation])
    
    if @product.save
      flash[:message] = 'Correcto'
    else
      flash[:error] = 'Error'
    end
    redirect_to product_product_translations_url(@product)
 end
  
  def edit
    @product_translation = @product.product_translations.find(params[:id])
  end

  def update
    @product_translation = @product.product_translations.find(params[:id])
    @product_translation.update_attributes(params[:product_translation])
    if @product_translation.save
      flash[:message] = 'Correcto'
      redirect_to product_product_translations_url(@product)
    else
      flash[:error] = 'Error'
      render :action => :edit
    end
  end

  def destroy
    @product_translation = @product.product_translations.find(params[:id])
    
    if @product_translation.destroy
      flash[:message] = 'Correcto'
    else
      flash[:error] = 'Error'
    end
    redirect_to product_product_translations_url(@product)
  end
  
  private
  def authorized?
    is_admin?
  end
  
  def get_product
    @product = Product.find(params[:product_id], :include => :product_translations)
#    @product = Product.find(params[:product_id])
  end
end

