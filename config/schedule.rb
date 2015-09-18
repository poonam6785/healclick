every 1.hour do
  command 'sudo logrotate /etc/logrotate.d/logrotate_healclick'
end

every 1.day, at: '4:00am' do
  rake 'symptoms:calculate_summaries_for_conditions'
  rake 'reminder:tracking:daily'
end

every 1.week, at: '4:00am' do
  rake 'reminder:tracking:weekly'
end

# Email digests
every 1.day, at: '7:00am' do
  rake 'notification:digest'
end