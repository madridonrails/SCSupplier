class OrderLine < ActiveRecord::Base

    belongs_to :order
    belongs_to :raw_product

    #validates_presence_of :received_qty
    validates_presence_of :order
    validates_presence_of :order_id
    validates_presence_of :raw_product
    validates_presence_of :raw_product_id

  validate :valid_qty
  validate :qty_greater_than_zero
  validate :received_qty_less_equal_qty

  
  protected

  def valid_qty
    rec = Integer(self.qty) rescue 0
    if (rec<=0)
       self.qty = 0
       errors.add('-', 'qty invalid !')
       false
    else
      true
    end
  end

  def qty_greater_than_zero
    rec = Integer(self.qty) rescue 0
    if (rec>0)
      self.qty = rec
      true
    else
      errors.add('-', 'qty <=0 !')
      false
    end
  end

  def received_qty_less_equal_qty
    rec = Integer(self.received_qty) rescue 0
    if (rec<=self.qty && rec >=0)
      self.received_qty = rec
      true
    else
      self.received_qty = rec
      if (rec<0)
        errors.add('-', 'received qty <0 !')
      else
        errors.add('-', 'received qty > qty !')
      end
      false
    end
  end

end
