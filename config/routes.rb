ActionController::Routing::Routes.draw do |map|
  map.root :controller => "sessions", :action => 'new'

  map.resources :orders do |order|
    order.resources :order_lines
  end

#map.resources :sales, :collection => {:pendig => :get} do |sale|
#    sale.resources :sale_lines
#  end

  map.resources :sales, :collection => {:pending => :get}, :has_many => :sale_lines

#  map.resources :sales, :collection => {:pending => :get}
#  map.resources :sale_lines
  
  map.resources :users
  map.resources :raw_products, :has_many => :raw_product_translations
#  map.resources :raw_products do |raw_product|
#    raw_product.resources :raw_product_translations
#  end
  map.resources :orders
  map.resources :order_lines
  map.resource :session
  map.resources :providers
  map.resources :products do |product|
    product.resources :assemblies
    product.resources :product_translations
  end

  map.resources :clients
  map.resources :locales, :member => {:view_sections => :get, :new_section => :get, :create_section => :post}
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
