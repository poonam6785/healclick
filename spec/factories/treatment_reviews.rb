# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :treatment_review do
    treatment_id 1
    content "MyText"
  end
end
