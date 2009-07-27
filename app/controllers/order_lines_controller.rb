class OrderLinesController < ApplicationController
  
  before_filter :login_required

  def index
    @order = Order.find(params[:order_id])
    @query_order = params[:order].blank? ? "order_lines.raw_product_id" : params[:order]
    @direction = params[:direction].blank? ? "asc" : params[:direction]

    @order_lines = @order.order_lines.find(:all,
      :order => "#{@query_order} #{@direction}"
    )
    
  end

  def create
      @order = Order.find(params[:order_id])
      params[:order_line][:received_qty]= "0"
      @order_line = @order.order_lines.create(params[:order_line])
      if (@order_line.save)
        flash[:notice] = 'Order Line was successfully created.'
      else
        flash[:error] = 'Error'
      end
      redirect_to order_order_lines_url(@order)
  end
  
  def edit
    @order = Order.find(params[:order_id])
    @order_line = @order.order_lines.find(params[:id])
  end

  def update
    @order = Order.find(params[:order_id])
    @order_line = @order.order_lines.find(params[:id])

    received_qty_prev = @order_line.received_qty

    @order_line.update_attributes(params[:order_line])
    if @order_line.save

      # control de stock
      received_qty_prev = @order_line.received_qty - received_qty_prev

      if received_qty_prev !=0

        mess = nil

        @order_line.raw_product.stock += received_qty_prev

        if @order_line.raw_product.stock <0
            mess = "Attention: Stock was to be= #{@order_line.raw_product.stock}. Set to 0"
            @order_line.raw_product.stock = 0
        end

        if !@order_line.raw_product.save
            flash[:error] = 'Line saved but error on Stock update!!!'
            render :action => :edit
        else
            flash[:message] = "Correcto"+ (mess == nil ? "":("<br/>"+mess))
            redirect_to order_order_lines_url(@order)
        end
        
      else
        flash[:message] = "Correcto"
        redirect_to order_order_lines_url(@order)
      end
    else
      flash[:error] = 'Error'
      render :action => :edit
    end
  end

  def destroy
    @order = Order.find(params[:order_id])
    @order_line = OrderLine.find(params[:id])

    # control de stock
    received_qty_prev = @order_line.received_qty
    raw_prod = @order_line.raw_product

    if @order_line.destroy

      # control de stock
      if received_qty_prev !=0
        mess = nil
        raw_prod.stock -= received_qty_prev
        if raw_prod.stock <0
            mess = "Attention: Stock was to be= #{raw_prod.stock}. Set to 0"
            raw_prod.stock = 0
        end
        if !raw_prod.save
           flash[:message] = 'Line removed correctly but error on stock update'
        else
           flash[:message] = "Correcto"+ (mess == nil ? "":("<br/>"+mess))
        end
      else
           flash[:message] = "Correcto"
      end
    else
      flash[:error] = 'Error'
    end
    redirect_to order_order_lines_url(@order)
  end

private

  def authorized?
    is_admin? || is_stock?
  end

  def access_denied
    if logged_in?
      redirect_to edit_user_url(current_user)
    else
      redirect_to root_url
    end
  end

 end
