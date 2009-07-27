class RawProductTranslationsController < ApplicationController
  before_filter :login_required
  before_filter :get_raw_product

  def index
    @raw_product_translations = @raw_product.raw_product_translations
  end
  
  def new
    @raw_product_translation = @raw_product.raw_product_translations.new
  end

  def create
    @raw_product.raw_product_translations.create(params[:raw_product_translation])
    
    if @raw_product.save
      flash[:message] = 'Correcto'
    else
      flash[:error] = 'Error'
    end
    redirect_to raw_product_raw_product_translations_url(@raw_product)
  end
  
  def edit
    @raw_product_translation = @raw_product.raw_product_translations.find(params[:id])
  end

  def update
    @raw_product_translation = @raw_product.raw_product_translations.find(params[:id])
    @raw_product_translation.update_attributes(params[:raw_product_translation])
    if @raw_product_translation.save
      flash[:message] = 'Correcto'
      redirect_to raw_product_raw_product_translations_url(@raw_product)
    else
      flash[:error] = 'Error'
      render :action => :edit
    end
  end

  def destroy
    @raw_product_translation = @raw_product.raw_product_translations.find(params[:id])
    
    if @raw_product_translation.destroy
      flash[:message] = 'Correcto'
    else
      flash[:error] = 'Error'
    end
    redirect_to raw_product_raw_product_translations_url(@raw_product)
  end
  
  private
  def authorized?
    is_admin?
  end
  
  def get_raw_product
    @raw_product = RawProduct.find(params[:raw_product_id], :include => :raw_product_translations)
  end
end

