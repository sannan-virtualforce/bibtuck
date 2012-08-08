Feature: Following another people
  In order to let users see the feeds of other users
  As a user
  I want to be able to follow another user

  Scenario: user 1 follows user 2
    Given I am signed in
    And there is one item posted by "Adam" "Smith" "adamsmith"
    When I am on the last item
    And I press "Follow Adam Smith"
    Then I should see "You are now following Adam Smith"
