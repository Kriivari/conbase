class GmMailer < ActionMailer::Base

  def gmrequest(body, from, to, group, subject)
    @body = body
    mail( :from => from, :to => to, :subject => @subject )
  end

end
