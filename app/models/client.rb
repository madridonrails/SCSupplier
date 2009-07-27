class Client < ActiveRecord::Base

  has_many :sales

  validates_presence_of :client_name

  
  def before_destroy
    if self.sales.find(:first, :conditions => "sales.client_id = "+self.id.to_s) != nil
      errors.add('-', 'No se puede eliminar. Existen ventas asociadas!')
      false
    else
      true
    end
  end
end
