class NotificationsMailer < ActionMailer::Base

  default from: "HealClick <noreply@healclick.com>"
  add_template_helper(ApplicationHelper)

  def welcome user
    return unless SystemSetting.get_boolean_value(:welcome_email_enabled)
    @subject = SystemSetting.get_value(:welcome_email_subject)
    @body = SystemSetting.get_value(:welcome_email_body)
    @body.sub!('{username}', user.username)
    mail(to: user.email, subject: @subject)
  end

  def new_message(message)
    @message = message
    
    mail(to: message.to_user.email, subject: "#{message.from_user.username} sent you a private message on HealClick")
  end

  def post_reply_created(comment, by_user)
    @comment = comment
    @by_user = by_user
    if comment.commentable.is_a?(Post) && comment.commentable.tracking_update?
      target = 'Tracking Update'
    else
      target = 'topic'
    end
    mail(to: comment.commentable.user.email, subject: "#{@comment.anonymous ? "Anonymous" : @by_user.username} replied to your #{target} on HealClick")
  end

  def photo_comment_created(comment, by_user)
    @comment = comment
    @by_user = by_user

    mail(to: comment.commentable.user.email, subject: "#{@comment.anonymous ? "Anonymous" : @by_user.username} added a comment to your photo on HealClick")
  end

  def reply_comment_created(comment, by_user)
    @comment = comment
    @by_user = by_user

    mail(to: comment.parent.user.email, subject: "#{@comment.anonymous ? "Anonymous" : @by_user.username} added a comment to your reply on HealClick")
  end

  def after_comment_created(comment, user_comment, by_user)
    @comment = comment
    @user_comment = user_comment
    @by_user = by_user

    mail(to: user_comment.user.email, subject: "#{@comment.anonymous ? "Anonymous" : @by_user.username} commented after your comment")
  end

  def new_post_action(comment, user)
    @comment = comment
    @user = user
    @by_user = comment.user

    mail(to: user.email, subject: "#{@comment.anonymous ? "Anonymous" : @by_user.username} just replied to a post you are following on HealClick")
  end

  def luved_comment(comment, by_user)
    @comment = comment
    @by_user = by_user

    mail(to: comment.user.email, subject: "#{by_user.username} LUVs your comment on HealClick")
  end

  def luved_reply(comment, by_user)
    @comment = comment
    @by_user = by_user

    mail(to: comment.user.email, subject: "#{by_user.username} LUVs your reply on HealClick")
  end

  def luved_photo_comment(comment, by_user)
    @comment = comment
    @by_user = by_user

    mail(to: comment.user.email, subject: "#{by_user.username} LUVs your comment on a photo on HealClick")
  end

  def luved_photo(photo, by_user)
    @photo = photo
    @by_user = by_user

    mail(to: photo.user.email, subject: "#{by_user.username} LUVs your photo on HealClick")
  end

  def luved_post(post, by_user)
    @post = post
    @by_user = by_user
    title = post.tracking_update? ? 'LUVs your tracking update on HealClick' : 'LUVs your post on HealClick'
    mail(to: post.user.email, subject: "#{by_user.username} #{title}")
  end

  def luved_user(user, by_user)
    @user = user
    @by_user = by_user

    mail(to: user.email, subject: "#{by_user.username} LUVs your profile on HealClick")
  end

  def is_being_followed(user, by_user)
    @user = user
    @by_user = by_user

    mail(to: user.email, subject: "#{by_user.username} added you to their Team on HealClick")
  end

  def marked_comment_as_helpful(markable, user)
    @markable = markable
    @user=user

    mail(to: markable.user.email, subject: "#{user.username} finds your comment helpful on HealClick")
  end

  def marked_reply_as_helpful(markable, user)
    @markable = markable
    @user=user

    mail(to: markable.user.email, subject: "#{user.username} finds your reply helpful on HealClick")
  end  

  def marked_photo_comment_as_helpful(markable)
    @markable = markable

    mail(to: markable.user.email, subject: "Someone marked your comment on a photo as helpful on HealClick")
  end  

  def marked_post_as_helpful(markable, user)
    @markable = markable
    @user = user
    title = @markable.tracking_update? ? 'finds your Tracking Update helpful on HealClick' : 'finds your post helpful on HealClick'
    mail(to: markable.user.email, subject: "#{user.username} #{title}")
  end

  def marked_review_as_helpful(markable, user)
    @markable = markable
    @user=user

    mail(to: markable.user.email, subject: "#{user.username} finds your review helpful on HealClick")
  end

  def marked_photo_as_helpful(markable)
    @markable = markable

    mail(to: markable.user.email, subject: "Someone marked your photo as helpful on HealClick")
  end

  def mentioned_on_a_comment(user, by_user, object, comment_id)
    @user = user
    @by_user = by_user
    @object = object
    @comment = Comment.find(comment_id)

    mail(to: user.email, subject: "#{@object.anonymous ? "Anonymous" : @by_user.username} mentioned you on a comment on HealClick")
  end

  def mentioned_on_a_reply(user, by_user, object)
    @user = user
    @by_user = by_user
    @object = object

    mail(to: user.email, subject: "#{@object.anonymous ? "Anonymous" : @by_user.username} mentioned you on a reply on HealClick")
  end

  def mentioned_on_a_photo_comment(user, by_user, object)
    @user = user
    @by_user = by_user
    @object = object

    mail(to: user.email, subject: "#{@object.anonymous ? "Anonymous" : @by_user.username} mentioned you on a photo comment on HealClick")
  end

  def mentioned_on_a_post(user, by_user, object)
    @user = user
    @by_user = by_user
    @object = object

    mail(to: user.email, subject: "#{@object.anonymous ? "Anonymous" : @by_user.username} mentioned you on a post on HealClick")
  end

  def tracking_reminder(user, type)
    @user = user

    mail(to: user.email, subject: "#{type.capitalize} Tracking Reminder")
  end

  def daily_digest(results, user)
    @results = results
    @user = user
    mail(to: user.email, subject: "Your daily digest on HealClick")
  end
end