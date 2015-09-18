require 'rubygems'
require 'aws/s3'

namespace :db do
  desc 'Backups the entire database to an sql file.'
  task :backup => :environment do
    db_config = Rails.configuration.database_configuration
    user = db_config[Rails.env]['username']
    host = db_config[Rails.env]['host']
    database = db_config[Rails.env]['database']
    password = db_config[Rails.env]['password']

    s3_url = 's3://healclick-db-backups'
    shared_path = '/apps/healclick/shared'    

    filename = "#{Rails.env}-backup-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.sql.bz2"

    Dir.mkdir("#{shared_path}/backups") unless Dir.exists?("#{shared_path}/backups")
    File.expand_path("#{shared_path}/backups/#{filename}")

    sh "mysqldump -u #{user} -h #{host} -p#{password} #{database} | bzip2 -c > #{shared_path}/backups/#{filename} && s3cmd put #{shared_path}/backups/#{filename} #{s3_url} 2>&1 && rm #{shared_path}/backups/#{filename}"
  end
end
