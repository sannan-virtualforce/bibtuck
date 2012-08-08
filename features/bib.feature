Feature: Bib an item
  In order to sell products
  As a user
  I want to be able to bib an item

  Scenario: Bib an item
    Given I am on the homepage
    And I am signed in
    When I follow "Bib"
    When I fill in "Name your piece" with "Coton dress"
    And I press "Preview"
    When I press "Preview your item"
    And I press "Bib"
