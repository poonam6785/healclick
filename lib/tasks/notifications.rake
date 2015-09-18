namespace :notification do
  task digest: :environment do
    User.joins(:received_notifications).where('notifications.created_at BETWEEN ? AND ?', 1.day.ago, Time.zone.now).group('users.id').map {|u| u.daily_digest} 
  end
end