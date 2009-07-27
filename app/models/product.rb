class Product < ActiveRecord::Base
  has_many :assemblies, :dependent => :destroy
  has_many :raw_products, :through => :assemblies

  has_many :product_translations, :dependent => :destroy
  has_many :translations, :class_name => 'ProductTranslation'
  translate_columns :name, :description

  validates_presence_of :reference, :name, :stock
  validate :stock_must_be_at_least_zero

  def before_destroy
    if SaleLine.find(:first, :conditions => "sale_lines.product_id = "+self.id.to_s) != nil
      errors.add('-', 'No se puede eliminar. Existen pedidos asociados!')
      false
    else
      true
    end
  end

protected
  def stock_must_be_at_least_zero
    if stock.nil? || stock < 0
      errors.add(:stock, 'can not be less than 0')
      false
    else
      true
    end
  end

end
