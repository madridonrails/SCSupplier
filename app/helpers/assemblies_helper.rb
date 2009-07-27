module AssembliesHelper
  def select_raw_products_for_assembly
    select(:assembly, "raw_product_id", list_raw_products, {:include_blank => false})
  end
  
  def select_raw_products_for_assembly_
    select(:assembly, "raw_product_id", list_raw_products, {:include_blank => @assembly.blank? || @assembly.new_record?})
  end
end
