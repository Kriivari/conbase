class InvoicePdf < Prawn::Document
  def initialize(invoice)
    super()
    define_grid(:columns => 5, :rows => 8, :gutter => 0)
    grid(0,4).bounding_box() do
      image "/usr/local/conbase/public/images/logo.png", :valign => :top, :position => :right, :width => 80
    end
    grid([0,0],[0,1]).bounding_box() do
      text "#{invoice.event.address}"
    end
    grid([1,0],[7,4]).bounding_box do
      text "Kaubamaja-lasku", :position => :center, :size => 14, :style => :bold
      move_down 20
      text "Laskutusosoite", :style => :bold
      text "#{invoice.billing_address}"
      move_down 20
      text "Asiakkaan viite", :style => :bold
      text "#{invoice.customer_reference}"
      move_down 20
      table( [
          ["Laskun numero", "Viitenumero", "Päiväys", "Eräpäivä"],
          ["#{invoice.id}","#{invoice.reference}","#{invoice.invoicedate.strftime('%-d.%-m.%Y')}","#{invoice.duedate.strftime('%-d.%-m.%Y')}"]
        ] )
      move_down 20

      rows = [ ["Tuote", "Kpl", "Yksikköhinta", "Alennus", "Yhteensä" ] ]

      if invoice.tables > 0
	rows << ["Ensimmäinen myyntipöytä", "#{[ invoice.tables, 1 ].min()}", {:content => "#{"%.2f" % invoice.tableprice.to_s} €", :align => :right}, "#{invoice.rebate}%", {:content => "#{"%.2f" % ([ invoice.tables, 1 ].min() * invoice.tableprice * (100-invoice.rebate) / 100).to_s} €", :align => :right}]
      end
      if invoice.tables > 1
          rows << ["Seuraavat myyntipöydät", "#{[ invoice.tables - 1, 0 ].max()}", {:content => "#{"%.2f" % invoice.secondprice.to_s} €", :align => :right}, "#{invoice.rebate}%", {:content => "#{"%.2f" % ([ invoice.tables - 1, 0 ].max() * invoice.secondprice * (100-invoice.rebate) / 100).to_s} €", :align => :right}]
      end
      if invoice.tickets > 0
          rows << ["Lisäranneke", "#{invoice.tickets}", {:content => "#{"%.2f" % invoice.ticketprice.to_s} €", :align => :right}, "#{invoice.rebate}%", {:content => "#{"%.2f" % (invoice.tickets * invoice.ticketprice * (100-invoice.rebate) / 100).to_s} €", :align => :right}]
      end
      if invoice.travelpasses > 0
          rows << ["Kulkulupa", "#{invoice.travelpasses}", {:content => "0.00 €", :align => :right}, "#{invoice.rebate}%", {:content => "0,00 €", :align => :right}]
      end

      for product_type in invoice.product_types
        unless Exhibitor.special_type( product_type )
          rows << [product_type.fullname, 1, {:content => "#{"%.2f" % product_type.price.to_s} €", :align => :right}, "#{invoice.rebate}%", {:content => "#{"%.2f" % (product_type.price * (100-invoice.rebate) / 100).to_s} €", :align => :right}]
        end
      end
      rows << [{:content => "Laskun loppusumma:", :font_style => :bold},"","","",{:content => "#{"%.2f" % invoice.total.to_s} €", :align => :right, :font_style => :bold}]
      table( rows )
      move_down 20

      text "Pankkiyhteys #{invoice.event.bankaccount}"
      text "Laskun eräpäivä #{invoice.duedate.strftime('%-d.%-m.%Y')}. Viivästyskorko korkolain mukainen."
      text "ALV 0%. Y-tunnus #{invoice.event.businesscode}."
    end
  end
end
