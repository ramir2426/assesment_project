class SystemController < ApplicationController

  skip_after_filter :verify_authorized
  skip_before_filter :authenticate_user!, only: [:developer_access]

  def developer_access
    session[:developer] = true
    redirect_to root_url
  end
end
