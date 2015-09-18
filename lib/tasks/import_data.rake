namespace :import do 
  
  task data: :environment do
    # puts "Creating Countries"
    # Rake::Task['countries:create']
    # puts "Done"
    # puts "Creating Categories"
    # Rake::Task['post_categories:create']
    # puts "Done"
    # puts "Creating Conditions"
    # Rake::Task['conditions:create']
    # puts "Done"
    puts "Importing Users"
    Rake::Task['import:users'].invoke
    puts "Done"
    puts "Importing Messages"
    Rake::Task['import:messages'].invoke
    puts "Done"
    puts "Importing Posts"
    Rake::Task['import:posts'].invoke
    puts "Done"
    puts "Importing Medical Info"
    Rake::Task['import:medical_info'].invoke
    puts "Done"
    puts "Importing Followings"
    Rake::Task['import:followings'].invoke
    puts "Done"
  end

  # Importing Users and their Photos
  task users: :environment do 
    User.delete_all
    Photo.delete_all

    Old::User.all.each do |old_user|
      
      # Name
      names = old_user.fullname.to_s.split(' ')
      first_name = names.shift
      last_name = names.join(' ')
      username = old_user.username
      
      # Gender
      gender  = 'male' if old_user.gender_id.to_i == 1
      gender  = 'female' if old_user.gender_id.to_i == 2
      gender  = '' if old_user.gender_id.to_i == 3

      email   = old_user.email

      setting = Old::EmailSetting.where(user_id: old_user.id).last

      if setting.present?      
        gets_email_for_private_message  = setting.whengetaprivatemessage
        gets_email_for_follower         = setting.whengetafollower
        gets_email_for_helpful          = setting.whengetahelpfulvote
        gets_email_when_mentioned       = setting.whengetmentionedasusername
        gets_email_when_reply           = setting.whengetareply
        gets_email_when_comment         = setting.whengetacomment
        gets_email_when_luv             = setting.whenGetLUV
        gets_email_when_subscribed      = setting.whenGetAnAlertForSubscribed
      end

      user = User.create! old_id: old_user.id,
                          first_name: first_name,
                          last_name: last_name,
                          active: old_user.isactive,
                          gender: gender,
                          username: username,
                          email: email,
                          password: '18273645',
                          password_confirmation: '18273645',
                          created_at: old_user.createdon,
                          updated_at: old_user.lastUpdated,
                          location: old_user.location,
                          bio: old_user.describeyourself,
                          birth_date: old_user.dob,
                          role: old_user.userrole.to_s.downcase,
                          profile_is_public: old_user.whocanseemyprofile != 'MEMBERS_ONLY',
                          photo_is_public: old_user.whocanseemymainphoto != 'MEMBERS_ONLY',
                          age_is_public: old_user.whocanseemyage != 'MEMBERS_ONLY',
                          gender_is_public: old_user.whocanseemygender != 'MEMBERS_ONLY',
                          bio_is_public: old_user.whocanseemydescribeyourself != 'MEMBERS_ONLY',
                          main_condition_is_public: old_user.whocanseemyprimarydiagnosis != 'MEMBERS_ONLY',
                          followed_users_is_public: old_user.whocanseewhomiamfollowing != 'MEMBERS_ONLY',
                          following_users_is_public: old_user.whocanseewhoisfollowingme != 'MEMBERS_ONLY',
                          provider: 'import',
                          main_condition_step: true,
                          medical_info_step: true,
                          basic_info_step: true,
                          finished_profile: true,
                          gets_email_for_private_message: gets_email_for_private_message,
                          gets_email_for_follower: gets_email_for_follower,
                          gets_email_for_helpful: gets_email_for_helpful,
                          gets_email_when_mentioned: gets_email_when_mentioned,
                          gets_email_when_reply: gets_email_when_reply,
                          gets_email_when_comment: gets_email_when_comment,
                          gets_email_when_comment_after: gets_email_when_comment_after,
                          gets_email_when_luv: gets_email_when_luv,
                          gets_email_when_subscribed: gets_email_when_subscribed

      old_user.photos.each do |old_photo|

        unless old_photo.originalphotofilepath.blank?
          file_path = Rails.root.join("lib", "assets", "photos", old_photo.originalphotofilepath)

          if File.exist?(file_path)
            File.unlink(file_path)
          end

          File.open(file_path, "ab") do |f|
            f.write RestClient.get "http://healclicks.s3.amazonaws.com/#{old_photo.originalphotofilepath}" rescue nil
          end

          photo = user.photos.create!(attachment: File.open(file_path, "r"), description: old_photo.caption, created_at: old_photo.addedon) rescue nil

          if (old_photo.isprimary) && photo.present?
            photo.type = 'CroppedPhoto'
            photo.save!
            photo = CroppedPhoto.find(photo.id)
            user.update_attribute(:profile_photo, photo)
          end
        end
        
      end

    end    
  end

  task photos: :environment do 
    Photo.delete_all

    Old::User.all.each do |old_user|

      user = User.find_by_old_id(old_user)

      old_user.photos.each do |old_photo|

        unless old_photo.originalphotofilepath.blank?
          file_path = Rails.root.join("lib", "assets", "photos", old_photo.originalphotofilepath)

          if File.exist?(file_path)
            File.unlink(file_path)
          end

          File.open(file_path, "ab") do |f|
            f.write RestClient.get "http://healclicks.s3.amazonaws.com/#{old_photo.originalphotofilepath}"
          end

          photo = user.photos.create!(attachment: File.open(file_path, "r"), description: old_photo.caption, created_at: old_photo.addedon)

          if old_photo.isprimary
            photo.type = 'CroppedPhoto'
            photo.save!
            photo = CroppedPhoto.find(photo.id)
            user.update_attribute(:profile_photo, photo)
          end
        end
        
      end
    end
    
  end

  # Importing Messages
  task messages: :environment do
    Message.delete_all

    Old::Message.all.each do |old_message|
      old_message_received = Old::MessagesReceived.find_by_message_id(old_message.id)

      from_user             = User.find_by_old_id(old_message.sent_user_id)
      to_user               = User.find_by_old_id(old_message_received.receiver_user_id)
      deleted_by_sender     = false
      deleted_by_recipient  = old_message_received.isdeleted
      created_at            = old_message.dateandtime
      subject               = old_message.subject
      content               = old_message.messagebody

      Message.create!(from_user: from_user,
                      to_user: to_user,
                      subject: subject,
                      content: content,
                      created_at: created_at,
                      deleted_by_sender: deleted_by_sender,
                      deleted_by_recipient: deleted_by_recipient,
                      old_id: old_message.id,
                      is_read: old_message.isread)
    end

    Message.all.each do |message|
      if message.old_id.present?
        old_message = Old::Message.find(message.old_id)
        message.update_attributes(reply_to_message: Message.find(old_message.reply_to)) rescue nil
      end
    end
  end

  # Importing Post Threads
  task posts: :environment do

    Post.delete_all
    Comment.delete_all
    Photo.where("post_id is not null").delete_all

    Old::DiscussionThread.all.each do |old_post|
      puts "Old Post ID: #{old_post.id}"

      post_category = PostCategory.where("lower(name) = ?", Old::DiscussionCategory.find(old_post.discussion_category_id).label.downcase).first

      title         = old_post.title
      content       = old_post.description
      created_at    = old_post.posteddate
      anonymous     = old_post.postedas == 'ANONYMOUS'
      photo_name    = old_post.picturePath
      user          = User.find_by_old_id(old_post.posted_user_id)
      post_category = post_category
      photo         = nil
      views_count   = old_post.viewcount
      locked        = old_post.islocked.to_i == 1
      deleted       = old_post.isdeleted

      # begin
        if photo_name.present?
          file_path = Rails.root.join("lib", "assets", "photos", photo_name)

          if File.exist?(file_path)
            File.unlink(file_path)
          end

          File.open(file_path, "ab") do |f|
            f.write RestClient.get "http://healclicks.s3.amazonaws.com/#{photo_name}" rescue nil
          end

          photo = Photo.create!(attachment: File.open(file_path, "r"))
        end
      # rescue
      #   puts "Could not get photo"
      # end

      post = user.posts.create!(title: title,
                                content: content,
                                created_at: created_at,
                                anonymous: anonymous,
                                post_category: post_category,
                                photo: photo,
                                views_count: views_count,
                                locked: locked,
                                deleted: deleted)

      Old::FlaggedAsHelpful.where(flag_id: old_post.flag_id).each do |old_helpful|
        post.helpfuls.create!(user: User.find_by_old_id(old_helpful.user_id))
      end

      Old::DiscussionFollower.where(discussion_id: old_post.id).each do |old_follower|
        post.post_followers.create!(user_id: User.find_by_old_id(old_follower.user_id))
      end

      old_comments = Old::Reply.where(discussion_id: old_post.id)

      old_comments.each do |old_comment|

        created_at  = old_comment.posteddate
        content     = old_comment.reply
        user        = User.find_by_old_id(old_comment.user_id)
        anonymous   = old_comment.postedas == 'ANONYMOUS'
        deleted     = old_comment.isdeleted.to_i == 1

        comment = post.comments.create!(created_at: created_at, 
                                        content: content, 
                                        user: user, 
                                        anonymous: anonymous, 
                                        locked: locked)

        Old::FlaggedAsHelpful.where(flag_id: old_comment.flag_id).each do |old_helpful|
          comment.helpfuls.create!(user: User.find_by_old_id(old_helpful.user_id))
        end

        old_subcomments = Old::Comment.where(reply_id: old_comment.id)

        old_subcomments.each do |old_subcomment|
        
          unless old_subcomment.isdeleted.to_i == 1

            sub_created_at = old_subcomment.posteddate
            sub_content    = old_subcomment.commentdescription
            sub_user       = User.find_by_old_id(old_subcomment.user_id)

            subcomment = comment.comments.create!(created_at: sub_created_at, content: sub_content, user: sub_user)

            Old::FlaggedAsHelpful.where(flag_id: old_subcomment.flag_id).each do |old_helpful|
              subcomment.helpfuls.create!(user: User.find_by_old_id(old_helpful.user_id))
            end

          end
        end
      end
    end
  end

  task post_photos: :environment do 
    Old::DiscussionThread.where("picturePath is not null and picturePath <> ''").each do |old_post|
      puts "Old Post ID: #{old_post.id}"
      post = Post.find_by_old_id(old_post.id)
      photo_name    = old_post.picturePath

      file_path = Rails.root.join("lib", "assets", "photos", photo_name)

      if File.exist?(file_path)
        File.unlink(file_path)
      end

      File.open(file_path, "ab") do |f|
        f.write RestClient.get "http://healclicks.s3.amazonaws.com/#{photo_name}" rescue nil
      end

      photo = Photo.create!(attachment: File.open(file_path, "r", post: post))
    end
  end

  # Import Medical info such as symptoms, treatments and diagnosis
  task medical_info: :environment do 
    Treatment.delete_all
    Symptom.delete_all
    UserCondition.delete_all

    Old::User.all.each do |old_user|

      user = User.find_by_old_id(old_user.id)
      old_medical_details_id = old_user.medical_details_id

      unless old_medical_details_id.blank?

        # Treatments
        Old::UserTreatmendetail.where(medical_details_id: old_medical_details_id).each do |old_treatment|

          created_at      = old_treatment.created
          updated_at      = old_treatment.lastUpdated
          treatment_name  = Old::Treatment.find(old_treatment.treatment_id).treatmentdescription
          started_on      = Date.parse("#{old_treatment.started}-01-01") rescue nil
          ended_on        = Date.parse("#{old_treatment.ended}-12-31") rescue nil
          is_public       = old_treatment.istreatmentpublic

          treatment = user.treatments.create!(created_at: created_at, 
                                              updated_at: updated_at,
                                              treatment: treatment_name,
                                              started_on: started_on,
                                              ended_on: ended_on,
                                              is_public: is_public)
        end

        # Symptoms
        Old::UserSymptomDetail.where(medical_details_id: old_medical_details_id).each do |old_symptom|

          created_at   = old_symptom.created
          updated_at   = old_symptom.lastUpdated
          is_public    = old_symptom.ispublicinfo
          symptom_name = Old::Symptom.find(old_symptom.symptomid).symptomdescription rescue nil
          level        = Old::Severity.find(old_symptom.severity_id).label rescue nil

          symptom = user.symptoms.create!(created_at: created_at,
                                          updated_at: updated_at,
                                          is_public: is_public,
                                          symptom: symptom_name,
                                          level: level)
        end

        # User Conditions
        Old::UserDiagnosticsDetail.where(medical_details_id: old_medical_details_id).each do |old_condition|
        
          condition_name = Old::DiagnosticsCode.find(old_condition.disgnosticscodeid).diagnosisname rescue nil
          condition = Condition.find_by_name(condition_name)

          if condition.blank?
            condition = Condition.create!(name: condition_name)
          end

          created_at = old_condition.created
          updated_at = old_condition.lastUpdated
          is_public  = old_condition.isshowdiagnosisinbio
          started_on = old_condition.diagnosisstartedon

          user_condition = user.user_conditions.create!(created_at: created_at,
                                                        updated_at: updated_at,
                                                        is_public: is_public,
                                                        started_on: started_on,
                                                        condition: condition)

          if old_condition.userdiagnosistype == 'PRIMARY'
            user.update_attributes(main_condition: condition)
          end

        end
      end
    end
  end

  task followings: :environment do

    UserFollower.delete_all

    Old::Following.all.each do |old_follower|
      followed_user = User.find_by_old_id(old_follower.following_user_id)
      follower_user = User.find_by_old_id(old_follower.follower_user_id)
      UserFollower.create!(followed_user: followed_user, following_user: follower_user)
    end

  end

end