class Exhibitor < ActiveRecord::Base
  belongs_to :person
  belongs_to :event
  has_and_belongs_to_many :product_types

  cattr_reader :per_page
  @@per_page = 50

  def total
    sum = 0
    r = 0
    if rebate
      r = rebate
    end
    if tables > 0
      table = product_types.select{|t| t.product.name == "Myyntipöytä"}

      firstTablePrice = table.first.price
      secondTablePrice = table.first.secondprice

      unless secondTablePrice
        secondTablePrice = firstTablePrice
      end

      if tables > 0
        sum = sum + (tables - 1) * secondTablePrice + firstTablePrice
      end
    end

    ticketPrice = ProductType.where( "name='Viikonloppu'" ).first.price
    sum = sum + tickets * ticketPrice

    for product_type in product_types
      unless Exhibitor.special_type( product_type )
        sum = sum + product_type.price
      end
    end
    return sum * (100 - r) / 100
  end

  def reference
    return ApplicationHelper.reference( event.year.to_s + "02", self )
  end

  def tablesize
    unless product_types && product_types.select{|t| t.product.name == "Myyntipöytä"}
      return
    end
    table = product_types.select{|t| t.product.name == "Myyntipöytä"}.first
    if table
      return table.name
    end
    return nil
  end

  def tables
    unless product_types && product_types.select{|t| t.product.name == "Myyntipöytä"}
      return 0
    end
    return product_types.select{|t| t.product.name == "Myyntipöytä" && t.name != "A-myyntipöytä" && t.name != "B-myyntipöytä"}.size
  end

  def tickets
    unless product_types && product_types.select{|t| t.name == "Viikonloppu"}
      return 0
    end
    return product_types.select{|t| t.name == "Viikonloppu"}.size
  end

  def travelpasses
    unless product_types && product_types.select{|t| t.product.name == "Myyjäpassi"}
      return 0
    end
    return product_types.select{|t| t.name == "Myyjäpassi"}.size
  end

  def tableprice
    if tables > 0
      return product_types.select{|t| t.product.name == "Myyntipöytä"}.first.price
    end
    return 0
  end

  def secondprice
    if tables > 0
      table = product_types.select{|t| t.product.name == "Myyntipöytä"}.first
      if table.secondprice
        return table.secondprice
      else
        return table.price
      end
    end
    return 0
  end

  def ticketprice
    return ProductType.find_by_name("Viikonloppu").price
  end

  def self.special_type( product_type )
    if product_type.product_id == 3 #Myyntipöytä
      return false if product_type.name == "A-myyntipöytä" || product_type.name == "B-myyntipöytä"
      return true
    end
    return true if product_type.id == 5 # Myyjäpassi
    return true if product_type.id == 3 #Viikonloppuranneke

    false
  end
end
