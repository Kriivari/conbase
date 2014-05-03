class StaffMailer < ActionMailer::Base

  def confirm(body, from, to, group, subject)
    if subject == nil || subject.length == 0
      @subject    = 'Vahvistus työvoimaan hyväksymisestä'
    else
      @subject    = subject
    end
    if body == nil || body.length == 0
      body = 'Sinut on hyväksytty työvoimaksi ryhmään ' + group + '.'
    end
    @body = body
    mail( :from => from, :to => to, :subject => @subject )
  end

end
