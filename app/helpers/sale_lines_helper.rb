module SaleLinesHelper


  def select_for_sale_line_products
    select(:sale_line, "product_id", list_products)
  end


end
