Feature: Tuck
  In order to let people buy some bibed stuff
  As a visitor
  I want to be able to browse bibed items

  Scenario: Tuck
    Given I am signed in
    And one item categorized "dresses" was bibed
    And I am on the home page
    And I follow "Tuck"
    Then I should see 1 photo
    When I follow "dresses"
    Then I should see 1 photo
