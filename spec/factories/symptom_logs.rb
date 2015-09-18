# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :symptom_log do
    symptom nil
    user nil
    date "2014-04-30"
    numeric_level 1
    rank 1
  end
end
