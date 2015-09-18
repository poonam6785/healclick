Feature: Post actions

  @javascript
  Scenario: Create post with Faq or Blog category
    Given log me in as admin
    Given Post categories exist
    When I'm on "everything" page
    Then Page should not have content "Blog"
    And I click on ".btn-something" as a selector
    And I fill in "post title" with "bingo"
    And I fill in "post content" with "content"
    And I select "FAQ" from "post_post_category_id"
    And I click on "Post"
    When I'm on "faq" page
    Then Page should have content "bingo"