Given /^create (\d+) objects of "([^\"]*)" model$/ do |count, model|
  users = FactoryGirl.create_list model.downcase.to_sym, count.to_i
end

Given /^Create "([^\"]*)" model with "([^\"]*)" equal to "([^\"]*)"$/ do |model, attribute, value|
  hash = {}
  hash[attribute.to_sym] = value
  FactoryGirl.create model.downcase.to_sym, hash
end

Given /^create a default user$/ do
  FactoryGirl.create :user, username: 'default', password: 'default', email: 'default@mail.ru'
end

Then /^"(.*?)" count should equal (\d+)$/ do |model, count|
  expect(model.constantize.all.size).to eq(count.to_i)
end