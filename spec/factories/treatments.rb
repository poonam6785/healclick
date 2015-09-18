# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :treatment do
    treatment "MyString"
    started_on "2013-09-21"
    ended_on "2013-09-21"
    user_id 1
    result_level "MyString"
  end
end
