class Notification < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  include Rails.application.routes.url_helpers

  NOTIFICATION_TYPES = %w(LUV FOLLOWING REPLIED HELPFUL_DISCUSSION HELPFUL_REPLY COMMENTED_ON_REPLY COMMENTED_AFTER HELPFUL_COMMENT HELPFUL_PHOTO MENTIONED_USER MENTIONED_USER_COMMENT MENTIONED_USER_REPLY LUV_POST LUV_REPLY LUV_COMMENT LUV_PHOTO MENTIONED_USER_PHOTO_COMMENT FOLLOWING_ACTION)
NOTIFICATION_DIGEST_CONFIG = {
                              :email_digest_when_comment_after => {
                                title: "Someone comments after my comment",
                                notification_type: ['COMMENTED_AFTER']
                              },
                              :email_digest_when_luv => {
                                title: "Someone Luvs my profile",
                                notification_type: ['LUV_PHOTO', 'LUV']
                              },
                              :email_digest_when_luv_post => {
                                title: "Someone Luvs my post",
                                notification_type: ['LUV_COMMENT', 'LUV_REPLY', 'LUV_POST']
                              },
                              :email_digest_when_subscribed => {
                                title: "Someone added a new reply to the item you are following on",
                                notification_type: ['FOLLOWING_ACTION']
                              },
                              :email_digest_when_comment => {
                                title: "Someone comments on my reply",
                                notification_type: ['COMMENTED_ON_REPLY']
                              },
                              :email_digest_when_reply => {
                                title: "Someone replies to my post",
                                notification_type: ['REPLIED']
                              },
                              :email_digest_when_mentioned => {
                                title: "Someone mentions me in a post or a comment",
                                notification_type: ['MENTIONED_USER_COMMENT', 'MENTIONED_USER_PHOTO_COMMENT', 'MENTIONED_USER_REPLY', 'MENTIONED_USER']
                              },
                              :email_digest_for_helpful => {
                                title: "Someone marks my content as helpful",
                                notification_type: ['HELPFUL_COMMENT', 'HELPFUL_REPLY', 'HELPFUL_DISCUSSION']
                              },
                              :email_digest_for_follower => {
                                title: "Someone adds me",
                                notification_type: ['FOLLOWING']
                              },
                              :email_digest_for_private_message => {
                                title: "I receive a new private message",
                                notification_type: ['FOLLOWING']
                              } # ignores messaging
                            }
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user, class_name: "User", touch: true
  belongs_to :notifiable, polymorphic: true
  belongs_to :comment

  scope :recent, lambda{order("created_at desc")}
  scope :unread, lambda{where("is_read = 'f' or is_read is null")}

  def self.n
    new
  end

  def read?
    is_read
  end

  def read!
    update_attribute(:is_read, true)
  end

  def self.comment_after(comment)
    if comment.parent.present?
      # comment.parent.comments.each do |user_comment|
      previous_comment = comment.parent.comments.where.not(user_id: comment.user.id).last
      if !previous_comment.nil? && previous_comment.user_id != comment.parent.user_id
        create!(from_user: comment.user,
            to_user: previous_comment.user,
            notifiable: comment,
            content: "[SENDER] commented \"#{n.truncate(comment.content, :length => 100, :omission => "...")}\" after your comment \"#{n.truncate(previous_comment.content, :length => 100, :omission => "...")}\"",
            notification_type: 'COMMENTED_AFTER',
            comment_id: comment.id)

        if ::SENDING_EMAILS
          NotificationsMailer.after_comment_created(comment, previous_comment, comment.user).deliver if previous_comment.user.gets_email_when_comment_after && !previous_comment.user.email_digest_when_comment_after?          
        end
      end
    end
  end

  def self.comment_created(comment)
    if comment.parent.present?
      return if comment.user == comment.parent.user

      create!(from_user: comment.user,
              to_user: comment.parent.user,
              notifiable: comment,
              content: "[SENDER] commented \"#{n.truncate(comment.content, :length => 100, :omission => "...")}\" to your reply [SUBJECT]",
              notification_type: 'COMMENTED_ON_REPLY',
              comment_id: comment.id)

      if ::SENDING_EMAILS
        NotificationsMailer.reply_comment_created(comment, comment.user).deliver if comment.parent.user.gets_email_when_comment && !comment.parent.user.email_digest_when_comment?                
      end
    else
      return if comment.user == comment.commentable.user

      if comment.commentable.is_a?(Post)
        if comment.commentable.tracking_update?
          content = "[SENDER] replied \"#{n.truncate(comment.content, :length => 100, :omission => "...")}\" to your [SUBJECT]"
        else
          content = "[SENDER] replied \"#{n.truncate(comment.content, :length => 100, :omission => "...")}\" to your #{comment.commentable.type.to_s.downcase} [SUBJECT]"
        end
        create!(from_user: comment.user,
                to_user: comment.commentable.user,
                notifiable: comment.commentable,
                content: content,
                notification_type: 'REPLIED',
                comment_id: comment.id)

        if ::SENDING_EMAILS
          NotificationsMailer.post_reply_created(comment, comment.user).deliver if comment.commentable.user.gets_email_when_reply && !comment.commentable.user.email_digest_when_reply?          
        end

      elsif comment.commentable.is_a?(Photo)
        create!(from_user: comment.user,
                to_user: comment.commentable.user,
                notifiable: comment,
                content: "[SENDER] commented \"#{n.truncate(comment.content, :length => 100, :omission => "...")}\" to your [PHOTO]",
                notification_type: 'REPLIED',
                comment_id: comment.id)

        if ::SENDING_EMAILS
          NotificationsMailer.photo_comment_created(comment, comment.user).deliver if comment.commentable.user.gets_email_when_comment
        end

      end
    end
  end

  def self.action_created(comment)
    return unless comment.commentable.respond_to?(:post_followers)

    comment.commentable.users.each do |user|

      unless user == comment.user
        create!(from_user: comment.user,
                to_user: user,
                notifiable: comment.commentable,
                content: "[SENDER] added a new reply to the #{comment.commentable.type.to_s.downcase} you are following on [SUBJECT]",
                notification_type: 'FOLLOWING_ACTION')

        if ::SENDING_EMAILS
          NotificationsMailer.new_post_action(comment, user).deliver if user.gets_email_when_subscribed && !user.email_digest_when_subscribed?          
        end

      end
    end
  end

  def self.luved_comment(user, comment)
    return if user == comment.user

    if comment.parent.present?
      create!(from_user: user,
              to_user: comment.user,
              notifiable: comment,
              content: "[SENDER] Luvs your comment [SUBJECT]",
              notification_type: 'LUV_COMMENT')

      if ::SENDING_EMAILS
        NotificationsMailer.luved_comment(comment, user).deliver if comment.user.gets_email_when_luv_post && !comment.user.email_digest_when_luv_post?
      end

    else
      if comment.commentable.is_a?(Post)
        create!(from_user: user,
                to_user: comment.user,
                notifiable: comment,
                content: "[SENDER] Luvs your reply [SUBJECT]",
                notification_type: 'LUV_REPLY')

        if ::SENDING_EMAILS
          NotificationsMailer.luved_reply(comment, user).deliver if comment.user.gets_email_when_luv_post && !comment.user.email_digest_when_luv_post?          
        end

      elsif comment.commentable.is_a?(Photo)
        create!(from_user: user,
                to_user: comment.user,
                notifiable: comment,
                content: "[SENDER] Luvs your comment on a [PHOTO]",
                notification_type: 'LUV_REPLY')

        if ::SENDING_EMAILS
          NotificationsMailer.luved_photo_comment(comment, user).deliver if comment.user.gets_email_when_luv_post && !comment.user.email_digest_when_luv_post?          
        end
      end
    end
  end

  def self.loved_photo(user, photo)
    return if user == post.user

    create!(from_user: user,
            to_user: photo.user,
            notifiable: photo,
            content: "[SENDER] luved your [PHOTO]",
            notification_type: 'LUV_PHOTO')

    if ::SENDING_EMAILS
      NotificationsMailer.luved_photo(photo, user).deliver if photo.user.gets_email_when_luv && !photo.user.email_digest_when_luv?
    end
  end

  def self.loved_post(user, post)
    return if user == post.user

    create!(from_user: user,
            to_user: post.user,
            notifiable: post,
            content: "[SENDER] Luvs your [SUBJECT]",
            notification_type: 'LUV_POST')

    if ::SENDING_EMAILS
      NotificationsMailer.luved_post(post, user).deliver if post.user.gets_email_when_luv_post && !post.user.email_digest_when_luv_post?

    end

  end

  def self.loved_user(from_user, to_user)
    return if from_user == to_user

    create!(from_user: from_user,
            to_user: to_user,
            notifiable: to_user,
            content: '[SENDER] luved your profile',
            notification_type: 'LUV')

    if ::SENDING_EMAILS
      NotificationsMailer.luved_user(to_user, from_user).deliver if to_user.gets_email_when_luv && !to_user.email_digest_when_luv?
    end
  end  

  def self.user_being_followed(from_user, to_user)
    return if from_user == to_user

    create!(from_user: from_user,
            to_user: to_user,
            notifiable: to_user,
            content: '[SENDER] added you to their Team',
            notification_type: 'FOLLOWING')

    if ::SENDING_EMAILS
      NotificationsMailer.is_being_followed(to_user, from_user).deliver if to_user.gets_email_for_follower && !to_user.email_digest_for_follower?      
    end
  end

  def self.marked_as_helpful(user, markable)
    return if markable.user == user

    if markable.is_a?(Comment)
      if markable.parent.present?
        create!(from_user: user,
                to_user: markable.user,
                notifiable: markable,
                content: '[SENDER] marked your comment on [SUBJECT] as helpful',
                notification_type: 'HELPFUL_COMMENT',
                comment_id: markable.id)

        if ::SENDING_EMAILS
          NotificationsMailer.marked_comment_as_helpful(markable, user).deliver if markable.user.gets_email_for_helpful && !markable.user.email_digest_for_helpful?        
        end
      else
        if markable.commentable.is_a?(Post)
          create!(from_user: user,
                  to_user: markable.user,
                  notifiable: markable,
                  content: "[SENDER] marked your reply on [SUBJECT] as helpful",
                  notification_type: 'HELPFUL_REPLY',
                  comment_id: markable.id)

          if ::SENDING_EMAILS
            NotificationsMailer.marked_reply_as_helpful(markable, user).deliver if markable.user.gets_email_for_helpful && !markable.user.email_digest_for_helpful?            
          end

        elsif markable.commentable.is_a?(Photo)
          create!(from_user: user,
                  to_user: markable.user,
                  notifiable: markable,
                  content: "[SENDER] marked your comment on a [PHOTO] as helpful",
                  notification_type: 'HELPFUL_REPLY',
                  comment_id: markable.id)

          if ::SENDING_EMAILS
            NotificationsMailer.marked_photo_comment_as_helpful(markable).deliver if markable.user.gets_email_for_helpful && !markable.user.email_digest_for_helpful?            
          end
        end
      end
    elsif markable.is_a?(Review)

      create!(from_user: user,
              to_user: markable.user,
              notifiable: markable,
              content: "[SENDER] marked your [SUBJECT] as helpful",
              notification_type: 'HELPFUL_DISCUSSION')

      if ::SENDING_EMAILS
        NotificationsMailer.marked_review_as_helpful(markable, user).deliver if markable.user.gets_email_for_helpful && !markable.user.email_digest_for_helpful?
      end

    elsif markable.is_a?(Post)
      content = markable.tracking_update? ? 'finds your Tracking Update helpful' : "[SENDER] marked your #{markable.type.to_s.downcase} on [SUBJECT] as helpful"
      create!(from_user: user,
              to_user: markable.user,
              notifiable: markable,
              content: content,
              notification_type: 'HELPFUL_DISCUSSION')

      if ::SENDING_EMAILS
        NotificationsMailer.marked_post_as_helpful(markable, user).deliver if markable.user.gets_email_for_helpful && !markable.user.email_digest_for_helpful?        
      end

    elsif markable.is_a?(Photo)
      create!(from_user: user,
              to_user: markable.user,
              notifiable: markable,
              content: "[SENDER] marked your [PHOTO] as helpful",
              notification_type: 'HELPFUL_PHOTO')
      
      if ::SENDING_EMAILS
        NotificationsMailer.marked_photo_as_helpful(markable).deliver if markable.user.gets_email_for_helpful && !markable.user.email_digest_for_helpful?
      end

    end
  end

  def self.user_got_mentioned(user, object)
    return if object.user == user || !user.is_a?(User)

    if object.is_a?(Comment)
      if object.parent.present?
        create!(from_user: object.user,
                to_user: user,
                notifiable: object,
                content: "[SENDER] mentioned you in \"#{n.truncate(object.content, :length => 100, :omission => "...")}\"",
                notification_type: 'MENTIONED_USER_COMMENT',
                comment_id: object.id)

        if ::SENDING_EMAILS
          NotificationsMailer.mentioned_on_a_comment(user, object.user, object, object.id).deliver if user.gets_email_when_mentioned && !user.email_digest_when_mentioned?          
        end

      else
        if object.commentable.is_a?(Photo)
          create!(from_user: object.user,
                  to_user: user,
                  notifiable: object,
                  content: "[SENDER] mentioned you in \"#{n.truncate(object.content, :length => 100, :omission => "...")}\"",
                  notification_type: 'MENTIONED_USER_PHOTO_COMMENT',
                  comment_id: object.id)

          if ::SENDING_EMAILS
            NotificationsMailer.mentioned_on_a_photo_comment(user, object.user, object).deliver if user.gets_email_when_mentioned && !user.email_digest_when_mentioned?
          end          
        else
          create!(from_user: object.user,
                  to_user: user,
                  notifiable: object,
                  content: "[SENDER] mentioned you in \"#{n.truncate(object.content, :length => 100, :omission => "...")}\"",
                  notification_type: 'MENTIONED_USER_REPLY',
                  comment_id: object.id)

          if ::SENDING_EMAILS
            NotificationsMailer.mentioned_on_a_reply(user, object.user, object).deliver if user.gets_email_when_mentioned && !user.email_digest_when_mentioned?
          end

        end
      end
    elsif object.is_a?(Post)
      create!(from_user: object.user,
              to_user: user,
              notifiable: object,
              content: "[SENDER] mentioned you in \"#{n.truncate(object.content, :length => 100, :omission => "...")}\"",
              notification_type: 'MENTIONED_USER')

      if ::SENDING_EMAILS
        NotificationsMailer.mentioned_on_a_post(user, object.user, object).deliver if user.gets_email_when_mentioned && !user.email_digest_when_mentioned?

      end      
    end
  end

  def target_url
    return unless notifiable.present?
    if (notifiable.is_a?(Comment) || notifiable_type == 'Comment') && Comment.find(notifiable_id).commentable.is_a?(Photo)
      "#{Rails.application.routes.url_helpers.user_photo_url(notifiable.commentable.user, notifiable.commentable)}#comment_#{notifiable.id}"
    elsif notifiable.is_a?(Post) || notifiable_type == 'Post'
      if comment.present?
        "#{Rails.application.routes.url_helpers.post_url(notifiable)}?expanded=true#comment_#{comment.id}"
      else
        Rails.application.routes.url_helpers.post_url(notifiable)        
      end
    elsif notifiable.is_a?(Comment) || notifiable_type == 'Comment'
      return unless notifiable.commentable.present?
      if comment.present? && comment.parent.present?
        "#{Rails.application.routes.url_helpers.post_url(notifiable.commentable)}?expanded=true&comment_id=#{comment.parent_id}#comment_#{comment.id}"
      else
        "#{Rails.application.routes.url_helpers.post_url(notifiable.commentable)}?expanded=true&comment_id=#{notifiable.id}#comment_#{notifiable.id}"
      end
    else
      Rails.application.routes.url_helpers.profile_url(from_user.username)
    end    
  end

  def unscoped_comment
    Comment.unscoped.find_by_id(self.comment_id)
  end

end
