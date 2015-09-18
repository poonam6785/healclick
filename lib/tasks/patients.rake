namespace :patients do 

  task run_match_script: :environment do     
    PatientMatch.where(from_user_id: nil).delete_all
    PatientMatch.where(to_user_id: nil).delete_all

    User.order("last_sign_in_at DESC").each do |u|
      u.save_my_tags      
      u.delay(priority: 100, queue: :patient_matches).populate_patient_matches_without_delay
    end
  end

  task remove_duplicates_patient_matches: :environment do    
    User.order("last_sign_in_at DESC").each do |u|
      u.delay(priority: 100, queue: :patient_matches).remove_duplicates_patient_matches_without_delay
    end
  end

  task update_to_dummy: :environment do
    if Rails.env.staging? || Rails.env.development?
      # Update all users password to 'password'
      ActiveRecord::Base.connection.execute("update users set encrypted_password = '$2a$10$t8m..jxQVsW2EwA6QFD2p.pZ3QBHf967czmFobuRiJPDWyH5Xa.ZK'")

      # Update user addresses to dummy
      count = User.count
      User.all.each_with_index do |u,i|
        name = Faker::Internet.user_name

        u.update_column(:username, name)
        u.update_column(:email, Faker::Internet.email(name))
        
        if (i * 100 / count) % 5 == 0
          puts 'Updated ' + (i * 100 / count).to_s + '% of users'
        end
      end
    end
  end

  task :prepare_staging_db do
    # delete all patient matches
    PatientMatch.where(score: 0).delete_all
    puts 'PatientMatches - Deleted'

    # delete all messages
    Message.delete_all
    puts 'Messages - Deleted'

    # delete delayed jobs
    Delayed::Job.delete_all
    puts 'Delayed Jobs - Deleted'
  end

  task :prepare_production_db do
    # delete all patient matches
    PatientMatch.where(score: 0).delete_all
    
    # delete delayed jobs
    # Delayed::Job.delete_all
    # puts 'Delayed Jobs - Deleted'
  end

  task update_logs: :environment do
    User.where("last_sign_in_at >= ?", DateTime.now - 3.months).each do |u|
      u.update_logs if u.update_treatment_logs == false
    end
  end
end