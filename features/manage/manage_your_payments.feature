@manage
Feature: Update the Payment details of the user under 'your account'
  As a singed in Blinkbox books user
  I need the ability to update my payment details
  So I can keep my account up to date

  Background:
    Given I am on the home page

  @ie @safari @unstable
  Scenario: Delete a stored card
    Given I have a stored card
    And I have signed in
    And I am on the Saved cards tab
    # Service fails to delete card sometimes which leads to false negative
    When I delete the first card from the list
    Then there are no cards in my account
    And "Your payment card has been deleted. You can add new cards to your account while making a purchase" message is displayed

   @pending
   Scenario: Cancel delete stored card
     Given I have a stored card
     And I have signed in
     And I am on the Saved cards tab feature
     When I click delete
     And select Keep on Delete card? pop-up
     Then my saved card is not deleted
     
  @data_dependent @ie @safari @CP-2063 @production
  Scenario: Change default card
    Given I have multiple stored cards
    And I have signed in
    And I am on the Saved cards tab
    When I set a different card as my default card
    Then Credit card set as default successfully message is displayed
    And the selected card is displayed as my default card

  Scenario: First time user checking Payment details after buying a book and saving payment details
    Given I have selected to buy a paid book from the Book details page
    And I register to proceed with the purchase
    When I complete purchase with new card by selecting to save Payment details
    Then I can see the payment card saved in my Payment details

  Scenario: First time user checking Payment details after buying a book and not saving payment details
    Given I have selected to buy a paid book from the Book details page
    And I register to proceed with the purchase
    When I complete purchase with new card by selecting not to save Payment details
    Then I have no saved payment cards in my account

  Scenario: Existing user checking Payment details after buying a book with saved payments
    Given I have a stored card
    And I have selected to buy a paid book from the Book details page
    And I sign in to proceed with the purchase
    When I complete purchase by paying with saved card
    Then my saved Payment details are not updated

  Scenario: Existing user checking Payment details after buying a book with new payment and saving payment details
    Given I have a stored card
    And I have selected to buy a paid book from the Book details page
    And I sign in to proceed with the purchase
    When I complete purchase with new card by selecting to save Payment details
    Then I can see the payment card saved in my Payment details

  Scenario: Existing user checking Payment details after buying a book with new payment and not saving payment details
    Given I have a stored card
    And I have selected to buy a paid book from the Book details page
    And I sign in to proceed with the purchase
    When I complete purchase with new card by selecting not to save Payment details
    Then my saved Payment details are not updated
