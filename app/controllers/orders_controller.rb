class OrdersController < ApplicationController
  

  before_filter :find_order, :only => [:show, :edit, :update, :destroy, :accept, :fabricate, :receive, :complete, :cancel]
  before_filter :login_required

  def find_order
    @order = Order.find(params[:id])
  end


  def index
   @filter = params[:filter]
   conditions = [ '1 = 1']
   @query_order = params[:order].blank? ? "orders.order_date" : params[:order]
   @direction = params[:direction].blank? ? "asc" : params[:direction]

   unless (@filter.blank?)
     if !@filter[:id].blank?
      conditions[0] << ' AND orders.id = ?'
      conditions << @filter[:id]
     else

     if (!@filter[:provider].blank?)
        conditions[0] << ' AND orders.provider_id = ?'
        conditions << @filter[:provider].gsub("/", "")
     end

     if (!@filter[:state].blank?)
        conditions[0] << ' AND orders.state = ?'
        conditions << @filter[:state].gsub("/", "")
     end

      if !@filter[:from].blank?
        if !@filter[:to].blank?
          if !@filter[:provider].blank?
            #TODO
          else
            conditions[0] << ' AND ( orders.order_date >= ?'
            conditions << @filter[:from].gsub("/", "")
            conditions[0] << ' AND orders.order_date <= ? )'
            conditions << @filter[:to].gsub("/", "")
          end
        else
          conditions[0] << ' AND orders.order_date >= ?'
          conditions << @filter[:from].gsub("/", "")
        end
      else
       if !@filter[:to].blank?
          conditions[0] << ' AND orders.order_date <= ?'
          conditions << @filter[:to].gsub("/", "")
       end
      end
    end
   end

   @orders = Order.paginate(
      :per_page => 10,
      :page => params[:page],
      :conditions => conditions,
      :order => "#{@query_order} #{@direction}"
    )
  end

  def edit
    @order_lines = OrderLine.find_by_order_id(@order.id)
  end

  def show
  end

  def new
    @order = Order.new
    @order.state = Order.initial_state
  end

  def create
    params[:order][:estimated_date] = get_date_from_multi_(params[:order],"estimated_date")
    params[:order][:state] = 'accept_pendant'
    @order = Order.new(params[:order])
    if (@order.save)
      flash[:notice] = 'Order was successfully created.'
      redirect_to(@order)
    else
      render :action => "new"
    end
  end

  def update
      if (!params[:order][:estimated_date].blank?)
        params[:order][:estimated_date] = get_date_from_multi_(params[:order],"estimated_date")
      end
      if @order.update_attributes(params[:order])
        flash[:notice] = 'Order was successfully updated.'
        redirect_to(@order)
      else
        render :action => "edit"
      end
  end

  def destroy
    @order.destroy
    redirect_to(orders_url)   
  end

  def accept
    @order = Order.find(params[:id])
    if @order.accept!
    redirect_to(@order)
    end
  end

  def cancel
    @order = Order.find(params[:id])
    if @order.cancel!
      redirect_to(@order)
    end
  end

  def fabricate
    @order = Order.find(params[:id])
    if @order.fabricate!
      redirect_to(@order)
    end
  end

  def receive
    @order = Order.find(params[:id])
    if@order.receive!
      redirect_to(@order)
    end
  end

  def complete
    @order = Order.find(params[:id])
    if @order.receive!
      redirect_to(@order)
    end
  end
  
  private

  #input 'aaaammdd'
  def valid_date(idate)
    s_idate = idate.to_s
    Time.local(Integer(s_idate[0..3]),Integer(s_idate[4..5]),Integer(s_idate[6..7]),0,0,0) rescue nil
  end

  # output 'aaaammdd'
  def get_date_from_multi_(params, name)
    y_1i = "year"
    m_2i = "month"
    d_3i = "day"

    m = params[name][m_2i].to_i
    if (m<10)
      sm = "0#{m}"
    else
      sm = "#{m}"
    end

    d = params[name][d_3i].to_i
    if (d<10)
      sd = "0#{d}"
    else
      sd = "#{d}"
    end

    ay = params[name][y_1i]

    params[name].delete(y_1i)
    params[name].delete(m_2i)
    params[name].delete(d_3i)

    "#{ay}#{sm}#{sd}"
  end

 # output 'aaaammdd'
  def get_date_from_multi(params, name)
    y_1i = "#{name}(1i)"
    m_2i = "#{name}(2i)"
    d_3i = "#{name}(3i)"

    m = params[m_2i].to_i
    if (m<10)
      sm = "0#{m}"
    else
      sm = "#{m}"
    end

    d = params[d_3i].to_i
    if (d<10)
      sd = "0#{d}"
    else
      sd = "#{d}"
    end

    ay = params[y_1i]

    params.delete(y_1i)
    params.delete(m_2i)
    params.delete(d_3i)

    "#{ay}#{sm}#{sd}"
  end

  def authorized?
    is_admin? || is_sales? || is_stock?
  end

  def access_denied
    if logged_in?
      redirect_to edit_user_url(current_user)
    else
      redirect_to root_url
    end
  end
  
end
