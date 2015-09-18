# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :treatment_log do
    treatment nil
    user nil
    date "2014-04-30"
    numeric_level 1
    currently_taking false
    take_today false
    current_dose "MyString"
    rank 1
  end
end
