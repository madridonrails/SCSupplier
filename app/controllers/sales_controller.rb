class SalesController < ApplicationController


  before_filter :find_sale, :only => [:show, :edit, :update, :destroy, :accept, :build, :send_sale, :complete, :cancel]
  before_filter :login_required

  def find_sale
    @sale = Sale.find(params[:id])
  end


  def index
   @filter = params[:filter]
   (current_user.is_admin? || current_user.is_stock?) ? conditions = ['1 = 1'] : conditions = ["sales.user_id = #{current_user.id}"]

   @query_order = params[:order].blank? ? "sales.sale_date" : params[:order]
   @direction = params[:direction].blank? ? "asc" : params[:direction]

   unless (@filter.blank?)
     if !@filter[:id].blank?
      conditions[0] << ' AND sales.id = ?'
      conditions << @filter[:id]
     else

      if (!@filter[:client].blank?)
        conditions[0] << ' AND sales.client_id = ?'
        conditions << @filter[:client].gsub("/", "")
      end

      if (!@filter[:state].blank?)
        conditions[0] << ' AND sales.state = ?'
        conditions << @filter[:state].gsub("/", "")
     end

      if !@filter[:from].blank?
        if !@filter[:to].blank?
            conditions[0] << ' AND ( sales.sale_date >= ?'
            conditions << @filter[:from].gsub("/", "")
            conditions[0] << ' AND sales.sale_date <= ? )'
            conditions << @filter[:to].gsub("/", "")
        else
          conditions[0] << ' AND sales.sale_date >= ?'
          conditions << @filter[:from].gsub("/", "")
        end
      else
       if !@filter[:to].blank?
          conditions[0] << ' AND sales.sale_date <= ?'
          conditions << @filter[:to].gsub("/", "")
       end
      end
    end
   end
     @sales = Sale.paginate(
        :per_page => 10,
        :page => params[:page],
        :conditions => conditions,
        :order => "#{@query_order} #{@direction}"
        )
  end

  def edit
    @sale_lines = SaleLine.find_by_sale_id(@sale.id)
  end

 	def show
  end

  def new
    @sale = Sale.new
  end

  def create
    params[:sale][:estimated_date] = get_date_from_multi_(params[:sale],"estimated_date")
    params[:sale][:state] = 'accept_pendant'
    @sale = Sale.new(params[:sale])
    if (@sale.save)
      flash[:notice] = 'Sale was successfully created.'
      redirect_to(@sale)
    else
      render :action => "new"
    end
  end

  def update
      if (!params[:sale][:estimated_date].blank?)
         params[:sale][:estimated_date] = get_date_from_multi_(params[:sale],"estimated_date")
      end
      if @sale.update_attributes(params[:sale])
        flash[:notice] = 'Sale was successfully updated.'
        redirect_to(@sale)
      else
        render :action => "edit"
      end
  end

  def pending
    @pending = Sale.products_to_order(current_user)
  end

  def destroy
    @sale.destroy
    redirect_to(sales_url)
  end

  def accept
    if @sale.accept!
      flash[:notice] = "Sale updated to accepted"
    else
      flash[:notice] = 'Error accepting this sale'
    end
    redirect_to(@sale)
  end

  def build
    if @sale.build!
      flash[:notice] = "Sale updated to built"
    else
      flash[:notice] = 'Error building this sale'
    end
    redirect_to(@sale)
  end

  def send_sale
    if @sale.send_sale!
      flash[:notice] = "Sale updated to sent"
    else
      flash[:notice] = 'Error sending this sale'
    end

    redirect_to(@sale)
  end

  def complete
    if @sale.complete!
      flash[:notice] = "Sale updated to completed"
    else
      flash[:notice] = 'Error completeing this sale'
    end
    redirect_to(@sale)
  end

  def cancel
    if @sale.cancel!
      flash[:notice] = "Sale updated to canceled"
    else
      flash[:notice] = 'Error canceling this sale'
    end
    redirect_to(@sale)
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
