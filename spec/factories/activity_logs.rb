# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity_log do
    user_id 1
    activity_id 1
    activity_type "MyString"
  end
end
