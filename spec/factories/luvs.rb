# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :luv do
    luvable_id 1
    luvable_type "MyString"
    user nil
  end
end
