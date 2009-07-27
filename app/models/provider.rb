class Provider < ActiveRecord::Base

  has_many :raw_products
  validates_presence_of :name

  def before_destroy
    if self.raw_products.find(:first, :conditions => "raw_products.provider_id = "+self.id.to_s) != nil
      errors.add('-', 'No se puede eliminar. Existen productos asociados!')
      false
    else
      true
    end
  end
    
end
