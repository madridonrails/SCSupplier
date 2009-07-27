# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  before_filter :set_locale
#  around_filter :set_locale
#  around_filter :set_language
  
  helper_method :is_admin?, :is_sales?, :is_stock? 

  def is_admin?
    logged_in? && current_user.is_admin?
  end
  
  def is_sales?
    logged_in? && current_user.is_sales?
  end
  
  def is_stock?
    logged_in? && current_user.is_stock?
  end

  private

  def set_locale
    I18n.locale = (current_user.locale.code rescue 'es-ES')
    Locale.global = I18n.locale
  end
  
#  def set_language
#    Locale.global = (current_user.locale.code rescue 'es-ES')
#    Gibberish.use_language((current_user.locale.code rescue 'es-ES')) { yield }
#  end
end
