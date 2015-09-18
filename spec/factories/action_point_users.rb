# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :action_point_user do
    user_id 1
    action "MyString"
    score 1
  end
end
