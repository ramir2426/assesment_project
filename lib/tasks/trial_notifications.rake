desc "Send free trial reminders"

task :free_trial_reminders => :environment do
  User.where("account_plan = 'trial' and free_trial_2_days_email is null and active_until < ?", 2.days.from_now).each do |user|
    AccountMailer.trial_about_to_end(user).deliver_now
    user.update_attribute(:free_trial_2_days_email, true)
  end

  User.where("account_plan = 'trial' and free_trial_ended_email is null and active_until < ?", Time.now).each do |user|
    AccountMailer.trial_has_ended(user).deliver_now
    user.update_attribute(:free_trial_ended_email, true)
  end
end