# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do

  sequence :email do |n|
    "email#{n}@example.com"
  end

  sequence :username do |n|
    "user#{n}"
  end

  sequence :first_name do |n|
    Faker::Name.first_name
  end

  sequence :last_name do |n|
    Faker::Name.last_name
  end  

  factory :user do
    first_name 
    last_name
    gender "male"
    birth_date 20.years.ago
    email
    username
    password "password"
    password_confirmation "password"
    basic_info_step true 
    main_condition_step true
    medical_info_step true
    finished_profile true
    factory :admin do
      is_admin true
    end
  end
end