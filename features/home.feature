Feature: Node-Hello Home page
  Visit Node-Hello Home Page

  Scenario: Home Page Visit
    Given I am a node-hello app user
    When I visit the home page
    Then I should be greeted with message "Hello World"