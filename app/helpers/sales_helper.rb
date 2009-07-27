module SalesHelper

  def list_sales_states

    res = {}
    Sale.states.each do |s|
      res[s] = s
    end

    return res.sort_by {|s| s.to_s}
  end

    def list_sales_states_hash

    res = {}
    Sale.states.each do |s|
      res[s] = s
    end

    res
  end

  def select_state_for_sales
    select (:sale, 'state', list_sales_states, {:selected => (@sale.new_record? ? Sale.initial_state : @sale.state.intern)})
  end
end
