# encoding: UTF-8

class AccountMailer < ActionMailer::Base

  default from: "\"resiboapp.com\" <support@resiboapp.com>"
  layout "mailer"

  def trial_about_to_end(user)
    @user = user
    mail to: @user.email, subject: "Only 2 days left on your ResiboApp free trial"
  end

  def trial_has_ended(user)
    @user = user
    mail to: @user.email, subject: "Your ResiboApp free trial expired"
  end
end
