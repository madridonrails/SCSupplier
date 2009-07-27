class RawProductTranslation < ActiveRecord::Base
  belongs_to :raw_product
  belongs_to :locale
  
  validates_presence_of :raw_product
  validates_presence_of :raw_product_id
  validates_presence_of :locale
  validates_presence_of :locale_id
  validates_presence_of :name
end
