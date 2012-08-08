Feature: Static pages
  In order to make the user more secure
  As a user
  I want to be able to see static pages

  Scenario: Show static pages
    Given I am on the homepage
    Then I should see "About"
    And I should see "How It Works"
    And I should see "Legal Stuff"
    And I should see "Team"
    And I should see "Contact Us"
