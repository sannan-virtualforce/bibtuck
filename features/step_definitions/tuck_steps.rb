Given /^I tucked an item$/ do
  item = Factory :item
  user = Factory :user
  user.tuck(item)
end

When /^I rate my experience$/ do
  choose "5"
  fill_in 'Comment', :with => "Genius"
end

Then /^I shouldn't be able to rate the same user twice$/ do
  visit new_user_experience_path(User.last)
  page.should have_content('You can\'t rate two times the same user')
end
