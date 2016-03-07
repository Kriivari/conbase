class ExhibitorMailer < ActionMailer::Base
  default :from => "myyntialue@ropecon.fi"

  def confirmation_email( event, exhibitor, exhibitorbooth, tables )
    @exhibitor = exhibitor
    @event = event
    @exhibitorbooth = exhibitorbooth
    @tables = tables
    mail( :to => @exhibitor.person.primary_email, :subject => @event.name + " - myyntialuevaraus" )
  end
end
