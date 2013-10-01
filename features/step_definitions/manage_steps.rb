When /^I select (.*?) link from drop down menu$/ do |link|
  click_link_from_my_account_dropdown(link)
end

And /^(.*?) tab is selected$/ do |tab_name|
  assert_tab_selected(tab_name)
end


Given /^I am on the (.*?) tab/ do |tab_name|
  click_link_from_my_account_dropdown(tab_name)
end

When /^I edit the first name and last name$/ do
  @first_name, @last_name = edit_personal_details
end

And /^I submit my personal details$$/ do
 click_button('Update personal details')
end

Then /^"(.*?)" message is displayed$/ do |message_text|
 find('[id="submit_success"]').text.eql?(message_text)
end


Then /^the first name and last name are as submitted$/ do
  find('[id="first_name"]').value.should eql(@first_name)
  find('[id="last_name"]').value.should eql(@last_name)
end

When /^I edit marketing preferences$/ do
 @after_status = edit_marketing_preferences
end

And /^marketing preferences are as submitted$/  do
  assert_marketing_preferences_changed(@after_status)
end

Given /^I have registered as new user$/ do
  click_sign_in_link
  click_register_button
  @email_address, @first_name, @last_name = enter_personal_details
  choose_a_valid_password('test1234')
  accept_terms_and_conditions
  submit_registration_details
end

When /^I edit email address$/ do
  @new_email_address = generate_random_email_address
  fill_form_element('email', @new_email_address)
end

And /^email address is as submitted$/  do
  find('[id="email"]').value.should.eql?(@new_email_address)
end

And /^I am on the Change your password section$/ do
  click_link_from_my_account_dropdown('Your personal details')
  find('.arrowedlink').click
end

When /^I change password$/ do
  @current_password = 'test1234'
  @new_password = 'test4321'
  update_password(@current_password,@new_password)
end

And /^I click Confirm button$/ do
  click_button('Confirm')
end

Then /^password is updated$/  do
  click_button('Sign out')
  delete_cookies
  visit('/')
  sign_in(@email_address,@new_password)
  assert_first_name(@first_name)
end


