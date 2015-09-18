# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :symptom do
    symptom "MyString"
    level "MyString"
    user_id 1
  end
end
