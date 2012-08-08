Feature: Signup with invitation code
  In order to block users without registration code
  As a user
  I want to be able to sign up with a given registration code

  Scenario: Internet user is signing up
    Given The registration code "eotuhnarc38"
    And I am on the home page
    And I follow "Sign up"
    And I fill in "Registration code" with "eotuhnarc38"
    And I press "Register"
    And I fill in "Username" with "testermctests"
    And I fill in "Email" with "test@gmail.com"
    And I fill in "Password" with "helloworld"
    And I fill in "Password confirmation" with "helloworld"
    And I press "Sign up"
    Then I should see "Logout"

  Scenario: Internet user is signing up
    Given The registration code "eotuhnarc38"
    And I am on the home page
    And I follow "Sign up"
    And I fill in "Registration code" with "notinbase"
    And I press "Register"
    Then I should see "is invalid"
    When I go to new user registration page
    Then I should see "Invalid invitation code. Please try again."
