class GmMailer < ActionMailer::Base

  def gmrequest(from, to, subject, event, person, games)
    @event = event
    @person = person
    @games = games
    mail( :from => from, :to => to, :subject => @subject )
  end

end
