class RawProduct < ActiveRecord::Base
  has_many :assemblies, :dependent => :destroy
  has_many :products, :through => :assemblies
  belongs_to :provider

  has_many :raw_product_translations, :dependent => :destroy

  has_many :translations, :class_name => 'RawProductTranslation'
  translate_columns :name, :description 

  validates_presence_of :name
  validates_presence_of :provider_id
  validates_presence_of :provider

  validate :stock_must_be_at_least_zero

  def before_destroy
    if OrderLine.find(:first, :conditions => "order_lines.raw_product_id = "+self.id.to_s) != nil
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
