# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :action_point do
    name "MyString"
    points_per_action 1
  end
end
