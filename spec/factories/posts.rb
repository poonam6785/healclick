# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post do
    title "MyString"
    content "MyText"
    user
  end
end