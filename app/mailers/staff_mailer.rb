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
    if group.adminemail
      to = group.adminemail
    else
      to = 'tyovoima@ropecon.fi'
    end
    mail( :from => 'tyovoima@ropecon.fi', :to => to, :subject => 'Henkilöitä lisätty Conbasen ryhmään' )
  end

  def staffshirt(event, person, details, price, reference)
    @event = event
    @person = person
    @details = details
    @price = price
    @reference = reference
    mail( :from => 'myyntituotteet@ropecon.fi', :to => person.primary_email, :subject => @event.name + ' - Paitatilauksesi' )
  end
end
