namespace :reminder do 
  namespace :tracking do

    task daily: :environment do
      User.active.where(tracking_email: User::TRACKING_EMAIL_TYPES['daily']).find_each do |user|
        NotificationsMailer.tracking_reminder(user, 'daily').deliver
      end
    end

    task weekly: :environment do
      User.active.where(tracking_email: User::TRACKING_EMAIL_TYPES['weekly']).find_each do |user|
        NotificationsMailer.tracking_reminder(user, 'weekly').deliver
      end
    end
  end

end