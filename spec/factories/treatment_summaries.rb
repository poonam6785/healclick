# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :treatment_summary do
    treatment_name "MyString"
    reviews_count 1
    latest_review_id 1
    review_average "9.99"
  end
end
