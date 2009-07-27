class SaleLine < ActiveRecord::Base

    belongs_to :sale
    belongs_to :product
    #comercial
    #belongs_to :user

    validates_presence_of :sale
    validates_presence_of :sale_id
    validates_presence_of :product
    validates_presence_of :product_id


    validate :valid_qty
    validate :qty_greater_than_zero
    validate :provided_qty_less_equal_qty
    validate :received_qty_less_equal_provided_qty

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

  def provided_qty_less_equal_qty
    rec = Integer(self.provided_qty) rescue 0
    if (rec<=self.qty && rec >=0)
      self.provided_qty = rec
      true
    else
      self.provided_qty = rec
      if (rec<0)
        errors.add('-', 'provided qty <0 !')
      else
        errors.add('-', 'provided qty > qty !')
      end
      false
    end
  end

  def received_qty_less_equal_provided_qty
    rec = Integer(self.received_qty) rescue 0
    if (rec<=self.provided_qty && rec >=0)
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
