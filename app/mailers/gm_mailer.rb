class GmMailer < ActionMailer::Base

  def gmrequest(from, to, group, subject, event, person, games)
    @event = event
    @person = person
    @games = games
    mail( :from => from, :to => to, :subject => @subject )
  end

end
