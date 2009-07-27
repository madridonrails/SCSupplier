module OrdersHelper

  def list_order_states

    res = {}
    Order.states.each{|s|
      res[s] = s
    }

    return res.sort_by{|s| s.to_s}
    
  end

  def list_order_states_hash
    res = {}
    Order.states.each{|s|
      res[s] = s
    }
    res
  end

  def select_state_for_orders
    select(:order, 'state', list_order_states ,{:selected => (@order.new_record? ? Order.initial_state : @order.state.intern) })
  end

private
  

  def comes_from_current?(transitions, current_state)
    transitions.each{ |transition|
      if transition.from.to_s== current_state
        return true
      end
    }
    return false
  end
end

