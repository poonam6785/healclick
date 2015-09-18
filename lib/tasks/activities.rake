namespace :activities do 

  task build_logs: :environment do 
    Post.all.each do |post|
      if post.is_a?(Review)
        post.user.activity_logs.create!(activity: post, title: "Review Created: ", created_at: post.created_at, updated_at: post.updated_at, anonymous: post.anonymous)
      else
        post.user.activity_logs.create!(activity: post, title: "Post Topic Created: ", created_at: post.created_at, updated_at: post.updated_at, anonymous: post.anonymous)
      end
    end

    Comment.all.each do |comment|
      if comment.parent.present?
        comment.user.activity_logs.create!(activity: comment, title: "Comment added to reply: ", created_at: comment.created_at, updated_at: comment.updated_at, anonymous: comment.anonymous)
      else
        comment.user.activity_logs.create!(activity: comment, title: "Reply added to: ", created_at: comment.created_at, updated_at: comment.updated_at, anonymous: comment.anonymous)
      end
    end
  end

end