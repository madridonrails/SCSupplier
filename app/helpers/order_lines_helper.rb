module OrderLinesHelper


  def select_for_order_line_raw_products_for_provider(provider_id)
    select(:order_line, "raw_product_id", list_raw_products_for_provider(provider_id))
  end

  def select_for_order_line_raw_products_for_provider_back(provider_id)
    select(:order_line, "raw_product_id", list_raw_products_for_provider(provider_id), {:include_blank => @order_line.new_record?})
  end

end
