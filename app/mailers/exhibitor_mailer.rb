class ExhibitorMailer < ActionMailer::Base
  default :from => "kaubamaja@ropecon.fi"

  def confirmation_email( event, exhibitor )
    @exhibitor = exhibitor
    @event = event
    mail( :to => @exhibitor.person.primary_email, :subject => @event.name + " - Kaubamajavaraus" )
  end
end
