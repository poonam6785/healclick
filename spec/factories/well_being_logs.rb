# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :well_being_log do
    well_being nil
    date "2014-05-01"
    numeric_level 1
  end
end
