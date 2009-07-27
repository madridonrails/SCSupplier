class Sale < ActiveRecord::Base

    acts_as_state_machine :initial => :accept_pendant

    state :accept_pendant
    state :accepted
    state :built
    state :sent
    state :completed
    state :canceled

    event :accept do
      transitions :from => :accept_pendant, :to => :accepted
    end

    event :build do
      transitions :from => :accepted, :to => :built
    end

    event :send_sale do
      transitions :from => :built, :to => :sent
    end

    event :complete do
      transitions :from => :sent, :to => :completed
    end

    event :cancel do
      transitions :from => :accept_pendant , :to => :canceled
      transitions :from => :accepted, :to => :canceled
      transitions :from => :built, :to => :canceled
      transitions :from => :sent, :to => :canceled
      transitions :from => :completed, :to => :canceled
    end

    has_many    :sale_lines, :dependent => :destroy
    belongs_to  :client
    belongs_to  :user

    validates_presence_of :sale_date
    validates_presence_of :estimated_date
    validates_presence_of :client
    validates_presence_of :client_id
    validates_presence_of :user
    validate :valid_estimated_date

    validate :can_cancel_sale
    validate :can_pre_accepted_sale

  def can_cancel_sale
    if (self.has_lines_with_provided_qty? && self.canceled? )
      errors.add('-', 'No se puede cancelar: provided_qty > 0')
      false
    else
      true
    end
  end

  def can_pre_accepted_sale
    if (self.has_lines_with_provided_qty? && self.accept_pendant? )
      errors.add('-', 'No se puede pasar a accept pendant: provided_qty > 0')
      false
    else
      true
    end
  end

  def can_delete_sale?
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

  def can_edit_provided_qty?
    ! (self.canceled? || self.completed? || self.accept_pendant?)
  end

  def can_edit_received_qty?
    self.sent?
  end
  
  def can_cancel_sale?
    ! (self.canceled? || has_lines_with_provided_qty? )
  end

  def can_pre_accept_sale?
    ! (self.accept_pendant? || has_lines_with_provided_qty? )
  end

  def has_lines_with_provided_qty?
     self.sale_lines.find(:first, :conditions => "sale_lines.provided_qty > 0") != nil
  end





    def Sale.products_to_order(current_user)

      sales = Sale.find(:all, :conditions => "sales.state != 'accept_pendant' and sales.state != 'completed' and sales.state !='canceled'" )


      # Paso 1: recorremos los pedidos de comerciales (de momento sin control de estado) y para cada línea obtenemos
      # el producto y la cantidad pedida.
      # salida: hash con producto => qty
      #
      # importante:
      # - Estos pedidos NO han sido servidos.
      # - Estos pedidos Han sido aceptados por Ximena.
      # - No existe envío parcial. Si hay que modificar un pedido se modifica: en líneas o cantidades
      # para ajustarlo a los que se va a enviar.
      # - Un pedido enviado se puede modificar ?: quizá por admin, en cualquier caso lo cambios que se produzcan:
      # (ajuste cantidad e línea, nueva línea y borrado) se ajustarán automáticamente en el Stock del producto afectado.
      # - Una cancelación de pedido enviado retorna al Stock las cantidades de forma automática.
      #
      #
      products_qtys = {}
      unless sales.empty?
        sales.each { |sale|
          sale_lines = sale.sale_lines
            sale_lines.each{|line|
            prov = Integer(line.provided_qty) rescue 0
            if products_qtys[line.product_id]!=nil
              products_qtys[line.product_id]+=(line.qty-prov)
            else
              products_qtys[line.product_id] =(line.qty-prov)
            end
          }
        }
      end

      products_qtys.each{|k,v|
         product = Product.find_by_id(k)
      }


      # hash auxiliar para guardar los @product
      products_objs = {}
      unless products_qtys.empty?
         products_qtys.each{|k,v|
            product = products_objs[k]
            if (product == nil)
              product = Product.find_by_id(k)
              products_objs[k] = product
            end
            # habremos de pedir lo que se ha pedido menos lo que ya tenemos (stock) Puede ser negativo si sobran
            products_qtys[k] = products_qtys[k] - product.stock
          }
      end


      # en products_qtys hemos obtenido el dato de los products pendientes de fabricar.
      # otra cosa distinta será si hay necesidad de pedir raw_products o no!!!
      # es lo que veremos a continuación

      # Veamos para cada producto los raw_products que hemos de pedir.
      # recorremos nuestra has de products_qtys y para uno de sus assemblies
      # guardaremos en raw_products_qty lo que habríamos de pedir
      raw_products_qtys = {}
      unless products_qtys.empty?
        products_qtys.each{|k,v|
          # sólo tenemos en cuenta los datos de los productos que necesitamos construir!!!
          if (v > 0)
            # accedemos a la hash.
            prod = products_objs[k]
            prod_assemblies = prod.assemblies
            unless prod_assemblies.empty?
              prod_assemblies.each{|assemblie|
                # ojo: es el número de piezas/unidad por el número de unidades
                if (raw_products_qtys[assemblie.raw_product_id] != nil)
                  raw_products_qtys[assemblie.raw_product_id]+= assemblie.quantity * v
                else
                  raw_products_qtys[assemblie.raw_product_id] = assemblie.quantity * v
                end
              }
            end
          end
        }
      end


      raw_products_qtys.each{|k,v|
        raw_product = RawProduct.find_by_id(k)
      }

      # auxliar para almacenar los raw_product
      raw_products_objs = {}
      # ahora obtengamos el pendiente de pedir: primero obtengamos lo actualmente pedido de raw_products
      raw_products_ordered_qty = {}
      # ojo al estado del Order!!! No incluido el estado a tener en cuenta
      # seguro que se puede optimizar pero de momento tiro.
      orders = Order.find(:all , :conditions => "orders.state != 'accept_pendant' and orders.state != 'completed' and orders.state !='canceled'" )
      unless orders.empty?
        orders.each{|order|
            order_lines = order.order_lines
            order_lines.each{|order_line|
              if (raw_products_ordered_qty[order_line.raw_product_id]!= nil)
                raw_products_ordered_qty[order_line.raw_product_id]+=order_line.qty
              else
                raw_products_ordered_qty[order_line.raw_product_id] =order_line.qty
              end
            }
        }
      end

      raw_products_ordered_qty.each{|k,v|
        raw_product = RawProduct.find_by_id(k)
      }



      # y después: lo que hemos de pedir lo necesario menos lo pedido menos el stock
      unless raw_products_qtys.empty?
        raw_products_qtys.each{|k,v|
            raw_product = raw_products_objs[k]
            if (raw_product == nil)
              raw_product = RawProduct.find_by_id(k)
              raw_products_objs[k] = raw_product
            end
            # si no hay nada pedido hay que pedir lo indicado menos el Stock
            if (raw_products_ordered_qty[k] == nil)
              raw_products_qtys[k] -= raw_product.stock
            else
            # si ha pedidos realizados: lo indicado menos lo ya pedido menos el Stock
              raw_products_qtys[k] = raw_products_qtys[k] - raw_products_ordered_qty[k] - raw_product.stock
            end
          }
      end

      raw_products_qtys.each{|k,v|
        raw_product = RawProduct.find_by_id(k)
      }

      salida = {}
      salida[:products] = {:products_qtys => products_qtys,:products_objs => products_objs }
      salida[:raw_products] = {:raw_products_qtys => raw_products_qtys,:raw_products_objs => raw_products_objs }

      salida
    end

        # Complejidad gestión automática stock
        #
        #
        # conociendo los productos y las cantidades hemos de actualizar las necesidades de cada producto
        # la necesidad de cada producto se incrementará en las unidades solicitadas en el pedido
        # pero la cantidad a pedir será la diferencia entre la necesidad anterior y la nueva.
        # Igualmente si se modifican a la baja las unidades de la línea de un pedido habrá de bajar la necesidad
        # en esa cantidad y si resulta que la diferencia de necesidad actual - anterior es negativa resulta que nos sobran
        # elementos pedidos!!!!
        #
        # [lin1-Pedido/Satisfecho = 10/0], stock = 0, necesidad antes = 0 , necesidad después = 10, -> gen orden 10-0  = 10, Pedido insatisfecho / ordenado no recibido = 10/10
        # [lin2-Pedido/Satisfecho = 7/0] , stock = 0, necesidad antes = 10, necesidad después = 17, -> gen orden 17-10 = 7,  17/17
        # [-----EntradaStock      = 8] ,   stock = 8, necesidad antes = 17, necesidad después = 9 (17-8), 17/9
        # [lin3-Pedido/Satisfecho = 3/0] , stock = 8, necesidad antes =  9, necesidad después = 12, -> gen orden 12-9  = 3, 20/12
        #
        # se produce una salida de stock de la lin-1, se ha satisfecho esa linea de pedido en 3 unidades:
        #
        # [lin1-Pedido/Satisfecho = 10/3,  stock = 5, necesidad antes = 12, necesidad después = 12, 17 / 12
        #
        # se produce una salida de stock de la lin-1, se ha satisfecho esa linea de pedido en 5 unidades:
        #
        # [lin1-Pedido/Satisfecho = 10/8,  stock = 0, necesidad antes = 12, necesidad después = 12, 12 / 12
        # [-----EntradaStock      = 7] ,   stock = 7, necesidad antes = 12, necesidad después = 5 (12-7), 12 / 5
        # [lin4-Pedido/Satisfecho = 15/0], stock = 7, necesidad antes =  5, necesidad después = 20, -> gen orden 20-5  = 15, 27 / 20
        #
        # se modifica línea de pedido lin5: bajamos 13 unidades: de 15 a 2
        #
        # [lin4-Pedido/Satisfecho = 2/0], stock = 7, necesidad antes =  20, necesidad después = 7, -> cancelar orden!!!: nos sobran 13 unidades de las pedidas (7-20 = -13),  14 / 20 !!!!
        #
        # se cancela el pedido de 7 unidades como consecuencia de X razón ->
        #
        # [lin2-Pedido/Satisfecho = 0/0], stock = 7, necesidad antes =  7, necesidad después = 0, -> 0 - 7 = - 7 !!!, 7 / 20 !!!!
        #
        # se produce entrada en Stock de 5 productos no proveniente de orden,
        #
        # [-----EntradaStockNoOrder      = 5] ,   stock = 12, necesidad antes = -7, necesidad después = -7-5 = -12, 7 / 20
        #
        #
        #



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
