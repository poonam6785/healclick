# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    from_user_id 1
    to_user_id 1
    notifiable_id 1
    notifiable_type "MyString"
    notification_type "MyString"
    content "MyText"
  end
end
