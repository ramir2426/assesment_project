class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :redirect_to_www
  before_action :authenticate_user!
  before_action :restrict_trial_access
  before_action :set_ab_test
  before_filter :allow_iframe_requests

  layout :layout_by_resource

protected

  def redirect_to_www
    if ENV['PING_URL'] == 'https://www.resiboapp.com'
      unless request.host == 'www.resiboapp.com' && request.protocol.include?('https')
        redirect_to 'https://www.resiboapp.com' + request.fullpath, status: 301
      end
    end
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def set_ab_test
    session[:ab_test] ||= rand(2) == 1 ? 'a' : 'b'
  end

  def restrict_trial_access
    if current_user && current_user.try(:active_days_left).to_i <= 0 && !request.fullpath.include?("subscription")
      redirect_to subscription_plans_url and return
    end
  end
end
