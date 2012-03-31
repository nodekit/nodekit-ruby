Feature: API Pull
  In order to get Haml code
  As a user
  I want to get the code throught the Api
  
  Scenario: Getting a document in Haml
    Given I have QntGyT3P00T secret and egxM28qoFkP token
     When I render the asd view in:
      | Haml |
      | Html |
      | Jade |
      | Json |
      | Coffeekup |
     Then I shoud get the code in:
      | Haml |
      | Html |
      | Jade |
      | Json |
      | Coffeekup |
  
  Scenario: Getting Documents
    Given I have QntGyT3P00T secret and egxM28qoFkP token
     When I query for documents
     Then I shoud get an array of documents
  
  Scenario: Document not found
    Given I have QntGyT3P00T secret and egxM28qoFkP token
     When I try to get test view as Haml
     Then I shoud get a 404 response
     
  Scenario: Unauthorized
    Given I have xxxx secret and xxxx token
     When I try to get test view as Haml
     Then I shoud get a 401 response
  
  Scenario: Bad Request
    Given I have xxx secret and egxM28qoFkP token
     When I try to get test view as Haml
     Then I shoud get a 400 response
  
  Scenario: Not Modified
    Given I have QntGyT3P00T secret and egxM28qoFkP token
     When I try to get asd view when not modified
     Then I shoud get a 304 response
