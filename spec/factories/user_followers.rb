# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_follower do
    followed_user_id 1
    following_user_id 1
  end
end
