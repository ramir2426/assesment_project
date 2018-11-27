class HomeController < ApplicationController

  skip_before_filter :authenticate_user!
  skip_after_filter :verify_authorized

  def index
    if current_user.nil?
      render 'static/homepage', layout: 'home'
    else
      redirect_to invoices_url
    end
  end
end