# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def show_state_machine_transitions(state_machine, options = {})
    html = ''
    transitions = state_machine.class.transition_table.keys

    if !options[:except].blank?
      transitions = transitions - options[:except]
    elsif !options[:only].blank?
      transitions = transitions & options[:only]
    end

    unless transitions.empty?
      transitions.each {|t|
        html += link_to("#{t.to_s}", :action => "#{t.to_s}", :id => state_machine.id ) if comes_from_current?(state_machine.class.transition_table[t], state_machine.state)
      }
    end

    return html
  end

  def order_transitions_by_user

    options = {}
     
    if current_user.is_stock?
      options = {:only => [:complete]}
    end

    return options

  end

  def sale_transitions_by_user

    options = {}

    if current_user.is_stock?
      options = {:only => [:fabricate, :send_sale]}
    elsif current_user.is_sales?
      options = {:only => [:complete]}
    end
    
  end

  def object_messages(obj = nil)
    if !obj.nil? && !obj.errors.blank?
      str_msg = '<div class="error">' + obj.errors.full_messages.join('<br/>') + '</div><br/>'
    elsif !flash[:error].blank?
      str_msg = '<div class="error">' + flash[:error] + '</div><br/>'
    elsif !flash[:notice].blank?
      str_msg = '<div class="error">' + flash[:notice] + '</div><br/>'
    elsif !flash[:message].blank?
      str_msg = '<div class="error">' + flash[:message] + '</div><br/>'
    else
      str_msg = ''
    end
    flash[:error] = ''
    flash[:notice] = ''
    flash[:message] = ''
    return str_msg
  end

  def get_order(field_name)
    order_hash = {:order => field_name}
    if (@query_order == field_name)
      order_hash[:direction] = (@direction == 'asc' ? 'desc' : 'asc')
    else
      order_hash[:direction] = 'asc'
    end
    return order_hash
  end


  def list_providers
    res = {}
    Provider.find(:all).map {|p|
     res[p.name] = p.id
    }
    res
  end

  def list_raw_products
    res = {}
    RawProduct.find(:all, :order => 'name').map {|r|
      res[r.name] = r.id
    }
    res
  end


  def list_clients
    res = {}
    Client.find(:all, :order => 'name').map {|r|
      res[r.name] = r.id
    }
    res
  end

  def list_products
    res = {}
    Product.find(:all, :order => 'name').map {|r|
      res[r.name] = r.id
    }
    res
  end

  def list_raw_products_for_provider(provider_id)
    res = {}
    RawProduct.find_all_by_provider_id(provider_id, :order => 'name').map {|r|
      res[r.name] = r.id
    }
    res
  end


  # 'aaaammdd' ->  'aaaa/mm/dd'  or ''
  def int_date_to_string(idate)
      vdate = Integer(idate)
      if (vdate> 10000000 && vdate<= 99999999)
        s_idate = idate.to_s
        "#{(s_idate[0..3])}/#{(s_idate[4..5])}/#{(s_idate[6..7])}"
      else
        ""
      end
  end


    #output 'aaaammdd'
  def get_current_date
    now_time = Time.now
    month = now_time.month
    day = now_time.day
    m = month <10 ? "0#{month}":month.to_s
    d = day <10 ? "0#{day}":day.to_s
    "#{now_time.year}#{m}#{d}"
  end

  def get_date_select(obj, var, time)
    if (time == nil)
      #select_date Time.now, :prefix => "#{obj}[#{var}]"
      select_date(Time.now, {:prefix => "#{obj}[#{var}]", :order => [:year, :month, :day], :use_month_names => %w(1 2 3 4 5 6 7 8 9 10 11 12) })
    else
      select_date(time, { :prefix => "#{obj}[#{var}]", :order => [:year, :month, :day], :use_month_names => %w(1 2 3 4 5 6 7 8 9 10 11 12) })
    end
  end

  # 'aaaammdd' -> time
  def get_time_from_aaaammdd(idate)
    if (idate == nil)
      idate = get_current_date
    end
    s_idate = idate.to_s
    Time.local(s_idate[0..3].to_i,s_idate[4..5].to_i,s_idate[6..7].to_i,0,0,0,0)
  end
  
  def yes_or_no(object = false)
    unless object.nil? || object.blank? || !object
      return 'S&iacute;'
    else
      return 'No'
    end
  end

  def select_locales_for_back(str_object, object)
    select(str_object, 'locale_id', Locale.find_non_master.map{|l| [l.code, l.id]} , {:include_blank => object.new_record?})
  end

  def select_locales_for(str_object, object)
    select(str_object, 'locale_id', Locale.find_non_master.map{|l| [l.code, l.id]} )
  end
end
