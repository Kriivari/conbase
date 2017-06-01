class ProgramMailer < ActionMailer::Base

  def programconfirm(event, person, program)
    @person = person
    @program = program
    @event = event
    mail( :from => 'ohjelma@ropecon.fi', :to => person.primary_email, :subject => @event.name + " - tervetuloa järjestämään ohjelmaa" )
  end

end
