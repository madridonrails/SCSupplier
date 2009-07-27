class ProductTranslation < ActiveRecord::Base
  belongs_to :product
  belongs_to :locale
  
  validates_presence_of :product
  validates_presence_of :product_id
  validates_presence_of :locale
  validates_presence_of :locale_id
  validates_presence_of :name
end
