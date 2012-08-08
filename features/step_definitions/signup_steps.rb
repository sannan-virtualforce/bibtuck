Given /^The registration code "([^"]*)"$/ do |reg_code|
  RegistrationCode.create(:registration_code => reg_code)
end

Given /^I am signed in$/ do
  Given %{The registration code "eotuhnarc38"}
  And %{I am on the home page}
  And %{I follow "Sign up"}
  And %{I fill in "Registration code" with "eotuhnarc38"}
  And %{I press "Register"}
  And %{I fill in "Username" with "testr1"}
  And %{I fill in "Email" with "test@example.com"}
  And %{I fill in "Password" with "helloworld"}
  And %{I fill in "Password confirmation" with "helloworld"}
  And %{I press "Sign up"}
end

Given /^I am featured$/ do
  user = User.last
  user.featured_at = Time.now
  user.save!
  user.featured_at.should_not be(nil)
end
