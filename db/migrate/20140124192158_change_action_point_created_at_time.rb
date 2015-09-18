class ChangeActionPointCreatedAtTime < ActiveRecord::Migration
  def up
    ActionPointUser.transaction do
      ActiveRecord::Base.connection.execute("TRUNCATE action_point_users")
      # Default values
      ActionPoints.helpful_vote_received = 10
      ActionPoints.luv_for_post = 10
      ActionPoints.topic_post = 40
      ActionPoints.reply_posted = 30
      ActionPoints.comment_posted = 30
      ActionPoints.profile_pic_uploaded = 10
      ActionPoints.about_me_posted = 15
      ActionPoints.luvs_sent = 25
      ActionPoints.favorite_added = 25
      ActionPoints.private_message_sent = 0
      ActionPoints.written_treatment_reviews = 40
      ActionPoints.post_photo_uploaded = 20

      Helpful.find_in_batches do |group|
        helpfuls = []
        group.each do |helpful|
          markable = helpful.markable
          if !markable.nil? && !markable.user.nil?
            helpfuls << markable.user.points.create(score: ActionPoints.helpful_vote_received, action: 'helpful_vote_received', actionable_type: markable.class.name, actionable_id: markable.id, manual_created_at: helpful.created_at)
          end
        end
      end

      Comment.find_in_batches do |group|
        comments = []
        group.each do |comment|
          next if comment.user.blank?
          if comment.parent.present?
            comments << comment.user.points.create(action: 'comment_posted', score: ActionPoints.comment_posted, actionable_type: 'Comment', actionable_id: comment.id, manual_created_at: comment.created_at)
          else
            comments << comment.user.points.create(action: 'reply_posted', score: ActionPoints.reply_posted, actionable_type: 'Comment', actionable_id: comment.id, manual_created_at: comment.created_at)
          end
        end
      end

      Message.find_in_batches do |group|
        group.each do |message|
          next if message.from_user.blank?
          message.from_user.points.create(score: ActionPoints.private_message_sent, action: 'private_message_sent', actionable_type: 'Message', actionable_id: message.id, manual_created_at: message.created_at)
        end
      end

      User.active.each do |user|
        user.points.create action: 'profile_pic_uploaded', actionable_type: 'User', actionable_id: user.id, score: ActionPoints.profile_pic_uploaded, manual_created_at: 2.months.ago unless user.profile_photo_id.blank?
      end

      Post.topics.each do |post|
        next if post.user.blank?
        post.user.points.create(action: 'topic_post', score: ActionPoints.topic_post, actionable_type: 'Post', actionable_id: post.id, manual_created_at: post.created_at)
      end

      Review.with_written_review.each do |review|
        next if review.user.blank?
        review.user.points.create action: 'written_treatment_reviews', score: ActionPoints.written_treatment_reviews, actionable_type: 'Review', actionable_id: review.id, manual_created_at: review.created_at
      end
      #
      Photo.where('attachment_file_name is not null and post_id is not null').each do |photo|
        unless photo.post.try(:user).nil?
          next if photo.post.try(:user).blank?
          photo.post.user.points.create action: 'post_photo_uploaded', score: ActionPoints.post_photo_uploaded, actionable_type: 'Photo', actionable_id: photo.id, manual_created_at: photo.created_at
        end
      end
    end
  end

  def down

  end
end
