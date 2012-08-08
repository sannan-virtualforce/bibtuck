Feature: Featured closet
  In order to emphasize the role of one seller
  As an admin
  I want to be able to put the spotlight on a closet

  Scenario: See the spotlight on a closet
    And I am signed in
    And I am featured
    When I go to the homepage
    When I follow "see more"
    Then I should be on my profile
