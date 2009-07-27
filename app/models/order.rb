class Order < ActiveRecord::Base

  validates_presence_of :state

  acts_as_state_machine :initial => :accept_pendant

  state :accept_pendant
  state :accepted
  state :fabrication
  state :receiving_pendant
  state :completed
  state :canceled

  event :accept do
    transitions :from => :accept_pendant, :to => :accepted
  end

  event :fabricate do
    transitions :from => :accepted, :to => :fabrication
  end

  event :receive do
    transitions :from => :fabrication, :to => :receiving_pendant
  end

  event :complete do
    transitions :from => :receiving_pendant, :to => :completed
  end

  event :cancel do
    transitions :from => :accept_pendant, :to => :canceled
    transitions :from => :receiving_pendant, :to => :canceled
    transitions :from => :accepted, :to => :canceled
    transitions :from => :fabrication, :to => :canceled
  end

    has_many    :order_lines, :dependent => :destroy
    belongs_to  :provider

    validates_presence_of :order_date
    validates_presence_of :estimated_date
    validates_presence_of :provider
    validates_presence_of :provider_id

    validate :valid_estimated_date
    validate :can_cancel_order
    validate :can_pre_accepted_order

  def can_cancel_order
    if (self.has_lines_with_received_qty? && self.canceled? )
      errors.add('-', 'No se puede cancelar: received_qty > 0')
      false
    else
      true
    end
  end

  def can_pre_accepted_order
    if (self.has_lines_with_received_qty? && self.accept_pendant? )
      errors.add('-', 'No se puede pasar a accept pendant: received_qty > 0')
      false
    else
      true
    end
  end

  def can_delete_order?
    self.canceled? || self.accept_pendant?
  end

  def can_add_remove_lines?
    ! (self.canceled? || self.completed? )
  end

  def can_edit_estimated_date?
    ! (self.canceled? || self.completed? )
  end

  def can_edit_qty?
    ! (self.canceled? || self.completed? )
  end

  def can_edit_received_qty?
    ! (self.canceled? || self.completed? || self.accept_pendant?)
  end

  def can_cancel_order?
    ! (self.canceled? || has_lines_with_received_qty? )
  end

  def can_pre_accept_order?
    ! (self.accept_pendant? || has_lines_with_received_qty? )
  end

  def has_lines_with_received_qty?
     self.order_lines.find(:first, :conditions => "order_lines.received_qty > 0") != nil
  end

  

  protected

  def valid_estimated_date
    if !valid_date(self.estimated_date)
      errors.add('-', 'Error en fecha estimada')
      false
    else
      true
    end
  end

  def valid_date(idate)
    begin
      s_idate = idate.to_s
      Date.valid_civil?(s_idate[0..3].to_i,s_idate[4..5].to_i,s_idate[6..7].to_i)
    rescue
      false
    end
  end

end
