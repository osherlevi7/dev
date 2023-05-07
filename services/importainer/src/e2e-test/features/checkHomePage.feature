Feature: checkHomePaage
  As a saas owner
  I want to have a working home page
  So that I can attract users

  Scenario: Check title
    When I open the url "http://192.168.50.242:7000"
    Then I expect that the title is "BeautifulSaaS - Beauty as a Service."
    And I expect the element "nav [href='/login']" contains text "Log in"
    And I expect the element "nav [href='/signup']" contains text "Sign up"
    And I expect the element "section.hero [href='/signup']" contains text "Get started now"

  Scenario: Check prices
    When I open the url "http://192.168.50.242:7000"
    Then I expect the element "#pricingStarter" contains text "29"
    And I expect the element "#pricingPro" contains text "99"
