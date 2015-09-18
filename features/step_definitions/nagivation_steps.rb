#encoding: utf-8
Given /^log me in$/ do
  @user = FactoryGirl.create :user, email: 'user@mail.ru', password: '12345678', password_confirmation: '12345678', username: 'user'
  visit root_path
  click_on 'LOG IN'
  fill_in 'user_login', with: 'user@mail.ru'
  fill_in 'user_password', with: '12345678'
  click_on 'Sign in'
end

Given /^log me in as admin$/ do
  @user = FactoryGirl.create :admin, email: 'user@mail.ru', password: '12345678', password_confirmation: '12345678', username: 'user'
  visit root_path
  click_on 'LOG IN'
  fill_in 'user_login', with: 'user@mail.ru'
  fill_in 'user_password', with: '12345678'
  click_on 'Sign in'
end

When /^I'm on "(.*?)" page$/ do |path|
  path = "#{path.parameterize(sep = '_')}_path"
  visit self.send(path.to_sym)
end

When /^I'm on "(.*?)" page with "(.*?)"$/ do |path, factory|
  page_path = "#{path.parameterize(sep = '_')}_path"
  factory = FactoryGirl.create factory
  visit self.send(page_path.to_sym, factory)
end

And /^I click on "([^\"]*)" within "([^\"]*)"$/ do |click_element, area|
  within area do
    click_on click_element
  end
end


And /^I click on "([^\"]*)"$/ do |click_element|
  click_on click_element
end

And /^I wait for a while$/ do
  sleep 1
end

And /^I fill in "([^\"]*)" with "([^\"]*)"$/ do |field, value|
  fill_in(field.gsub(' ', '_'), with: value)
end

And /^I fill in "([^\"]*)" with "([^\"]*)" as a rich redactor$/ do |field, value|
  page.execute_script "$('#{field}').redactor('insertText', '#{value}')"
end

And /^I click on "([^\"]*)" as a selector$/ do |selector|
  find(selector).click
end

And /^I fill in "([^\"]*)" with "([^\"]*)" within "([^\"]*)"$/ do |field, value, area|
  within area do
    fill_in(field.gsub(' ', '_'), with: value)
  end
end

And /^I select "([^\"]*)" from "([^\"]*)"$/ do |value, field|
  select(value, from: field)
end

Then /Page should have content "([^\"]*)"/ do |content|
  expect(page).to have_content(content)
end

Then /Page should not have content "([^\"]*)"/ do |content|
  expect(page).to have_content(content)
end

Then /Page should have selector "([^\"]*)"/ do |selector|
  page.should have_selector(selector)
end

Then /^I should get a PDF file$/ do
  response_headers["Content-Type"].should eq("application/pdf")
end