module RawProductsHelper

  def select_providers_for_raw_products
    select(:raw_product, "provider_id", list_providers, {:include_blank => false})
  end
  
  def select_providers_for_raw_products_
    select(:raw_product, "provider_id", list_providers, {:include_blank => @raw_product.new_record?})
  end
 end
