class SaleLinesController < ApplicationController

  before_filter :login_required

  def index
    @sale = Sale.find(params[:sale_id])

    @query_order = params[:order].blank? ? "sale_lines.product_id" : params[:order]
    @direction = params[:direction].blank? ? "asc" : params[:direction]

    @sale_lines = @sale.sale_lines.find(:all,
      :order => "#{@query_order} #{@direction}"
    )
    
  end

  def create
      @sale = Sale.find(params[:sale_id])
      params[:sale_line][:provided_qty] = "0"
      params[:sale_line][:received_qty] = "0"
      @sale_line = @sale.sale_lines.create(params[:sale_line])
      if (@sale_line.save)
        flash[:notice] = 'Sale Line was successfully created.'
      else
        flash[:error] = 'Error'
      end
      redirect_to sale_sale_lines_url(@sale)
  end
  
	def edit
    @sale = Sale.find(params[:sale_id])
    @sale_line = @sale.sale_lines.find(params[:id])
  end

  def update
    @sale = Sale.find(params[:sale_id])
    @sale_line = @sale.sale_lines.find(params[:id])
    # control de stock
    provided_qty_prev = @sale_line.provided_qty       
    @sale_line.update_attributes(params[:sale_line])
    if @sale_line.save      
      # control de stock
      provided_qty_prev = provided_qty_prev - @sale_line.provided_qty
      if provided_qty_prev !=0
        mess = nil
        @sale_line.product.stock += provided_qty_prev
        if @sale_line.product.stock <0
            mess = "Attention: Stock was to be= #{@sale_line.product.stock}. Set to 0"
            @sale_line.product.stock = 0
        end
        if !@sale_line.product.save
          flash[:error] = @sale_line.product.errors.full_messages.to_s + " "+ @sale_line.product.stock.to_s #'Line saved but error on Stock update!!!'
          render :action => :edit
        else
          flash[:message] = "Correcto"+ (mess == nil ? "":("<br/>"+mess))
          redirect_to sale_sale_lines_url(@sale)
        end
      else
        flash[:message] = "Correcto"
        redirect_to sale_sale_lines_url(@sale)
      end      
    else
      flash[:error] = 'Error'
      render :action => :edit
    end
  end

	def destroy
    @sale = Sale.find(params[:sale_id])
    @sale_line = SaleLine.find(params[:id])

    # control de stock
    provided_qty_prev = @sale_line.provided_qty
    prod = @sale_line.product

    if @sale_line.destroy

      # control de stock
      if provided_qty_prev !=0
        mess = nil
        prod.stock += provided_qty_prev
        if prod.stock <0
            mess = "Attention: Stock was to be= #{prod.stock}. Set to 0"
            prod.stock = 0
        end
        if !prod.save
           flash[:message] = 'Line removed correctly but error on stock update'
        else
           flash[:message] = "Correcto" + (mess == nil ? "":("<br/>"+mess))
        end
      else
        flash[:message] = "Correcto"
      end      
    else
      flash[:error] = 'Error'
    end
    redirect_to sale_sale_lines_url(@sale)
  end

private
  
  def authorized?
    is_admin? || is_stock? || (is_sales? && Sale.find(params[:sale_id]).user.id == current_user.id)
  end

  def access_denied
    if logged_in?
      redirect_to edit_user_url(current_user)
    else
      redirect_to root_url
    end
  end
end
