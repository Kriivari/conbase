class StaffMailer < ActionMailer::Base

  def staffrequest(body, from, to, group, subject, event, person)
    @event = event
    @person = person
    if subject == nil || subject.length == 0
      @subject    = 'Vahvistus työvoimaan ilmoittautumisesta'
    end
    if body == nil || body.length == 0
      body = 'Olet ilmoittautunut työvoimaksi ryhmään ' + group + '.'
    end
    @body = body
    mail( :from => from, :to => to, :subject => @subject )
  end

  def staffconfirm(event, group, person, body)
    if body == nil
      body = ''
    end
    @body = body
    @person = person
    @group = group
    @event = event
    mail( :from => 'tyovoima@ropecon.fi', :to => person.primary_email, :subject => @event.name + " - tervetuloa tapahtumaan" )
  end

  def staffnotify(group, people)
    @people = people
    @group = group
    mail( :from => 'tyovoima@ropecon.fi', :to => group.adminemail, :subject => 'Henkilöitä lisätty Conbasen ryhmään' )
  end
end
