class ProgramitemSweeper < ActiveRecord::Observer
  observe Programitem

  def after_create(programitem)
    expire_public_pages
  end

  def after_update(programitem)
    expire_public_pages
  end

  def after_destroy(programitem)
    expire_public_pages
  end

  private
  def expire_public_pages
    expire_page(:controller => 'programs', :action => 'public')
    expire_page(:controller => 'programs', :action => 'contv')
    expire_page(:controller => 'programs', :action => 'csv')
  end
end
