class StaticController < ApplicationController

  skip_before_filter :authenticate_user!
  skip_after_filter :verify_authorized

  def show
    render params[:page], layout: 'home'
  end
end