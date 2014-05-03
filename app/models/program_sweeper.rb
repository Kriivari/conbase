class ProgramSweeper < ActiveRecord::Observer
  observe Program
  observe Programitem

  def after_create(program)
    expire_public_pages
  end

  def after_update(program)
    expire_public_pages
  end

  def after_destroy(program)
    expire_public_pages
  end

  private
  def expire_public_pages
    expire_page(:controller => 'programs', :action => 'public')
    expire_page(:controller => 'programs', :action => 'contv')
    expire_page(:controller => 'programs', :action => 'csv')
  end
end
