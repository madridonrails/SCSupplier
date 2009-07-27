class Assembly < ActiveRecord::Base
  belongs_to :raw_product
  belongs_to :product

  validates_presence_of :raw_product_id, :product_id, :quantity


  validate :quantity_greater_than_zero

  def quantity_greater_than_zero
    qty = Integer(self.quantity) rescue 0
    if (qty <= 0 )
      errors.add('-', 'qty ha de ser > 0')
      false
    else
      true
    end
  end


end
