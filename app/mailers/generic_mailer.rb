class GenericMailer < ActionMailer::Base

  def email( event, sender, tolist, subject, body )
    @body = body
    mail( :from => sender, :to => tolist, :bcc => sender, :subject => event.name + " - " + subject  )
  end
end
