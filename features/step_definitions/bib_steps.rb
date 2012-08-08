When /^I attach a photo$/ do
  # number.to_i.times do |i|
  # attach_file "Photo #{i}", File.expand_path("public/images/grid.png")
  attach_file "Image", File.expand_path("public/images/grid.png")
  # end
end

When /^I fill in all the mandatory fields of the information page$/ do
  fill_in('Name your piece', :with => 'Coton dress')
  select('dresses', :from => 'Category')
  select('0, xs', :from => 'Size')
end

Given /^one item categorized "([^"]*)" was bibed$/ do |category|
  @category = Factory(:category, :name => category)
  @item = Factory(:item, :category => @category)
  @item.bib!
end

Then /^I should see 1 photo$/ do
   page.has_selector?('.item img')
end

Given /^there is one item posted by "([^"]*)"$/ do |username|
  Factory :item, :user => Factory(:user,
                                  :username => username)
end

Given /^there is one item posted by "([^"]*)" "([^"]*)" "([^"]*)"$/ do |first_name, last_name, username|
  Factory :item, :user => Factory(:user,
                                  :first_name => first_name,
                                  :last_name  => last_name,
                                  :username   => username)
end
