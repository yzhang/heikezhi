class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_lang

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  private
  def set_lang
    return unless request.env['HTTP_ACCEPT_LANGUAGE']
    accept_lang = request.env['HTTP_ACCEPT_LANGUAGE'].split(',').first
    lang, country = accept_lang.split('-')
    locale = "#{lang}-#{country.try(:upcase)}"
    locale = 'en' unless ['en', 'zh-CN', 'zh-TW'].include?(locale)
    I18n.locale = locale
  end

  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      '/mine'
    end
  end

  def render_404(exception)
    logger.info "Not Found: '#{request.fullpath}'.\n#{exception.class} error was raised for path .\n#{exception.message}"
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/error_404', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    logger.info "System Error: Tried to access '#{request.fullpath}'.\n#{exception.class} error was raised for path .\n#{exception.message}"
    @error = exception
    respond_to do |format|
      format.html { render template: 'errors/error_500', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end
end
