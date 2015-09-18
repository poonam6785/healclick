# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    from_user_id 1
    to_user_id 1
    reply_to_message_id 1
    subject "MyString"
    content "MyText"
    deleted_by_sender false
    deleted_by_recipient false
    is_read false
  end
end
