Feature: Start and stop nodes within Cucumber

    Scenario: Setup and start a node
        Given I setup and start "node1" on port "8098"
        Then I should be able to connect to "http://127.0.0.1:8098/jiak"
        
    Scenario: Put and get a key
        Given I setup and start "node1" on port "8098"
        When I set bucket schema "test" to '{}' on "http://127.0.0.1:8098/jiak"
        And I put '{"bucket":"test", "key":"test", "object":{}, "links":[]}' in "http://127.0.0.1:8098/jiak"
        Then I get the key "test" from the bucket "test" on "http://127.0.0.1:8098/jiak"
        
    Scenario: Setup a two node cluster
        Given I setup and start "node1" on port "8098"
        And I setup and start "node2" on port "8099"
        And I join "node2" to "node1"
        When I set bucket schema "test" to '{}' on "http://127.0.0.1:8098/jiak"
        And I put '{"bucket":"test", "key":"test", "object":{}, "links":[]}' in "http://127.0.0.1:8098/jiak"
        Then I get the key "test" from the bucket "test" on "http://127.0.0.1:8098/jiak"
        And I get the key "test" from the bucket "test" on "http://127.0.0.1:8099/jiak"
        
    Scenario: Setup a three node cluster
        Given I setup and start "node1" on port "8098"
        And I setup and start "node2" on port "8099"
        And I setup and start "node3" on port "8100"
        And I join "node2" to "node1"
        And I join "node3" to "node1"
        When I set bucket schema "test" to '{}' on "http://127.0.0.1:8098/jiak"
        And I put '{"bucket":"test", "key":"test", "object":{}, "links":[]}' in "http://127.0.0.1:8098/jiak"
        Then I get the key "test" from the bucket "test" on "http://127.0.0.1:8098/jiak"
        And I get the key "test" from the bucket "test" on "http://127.0.0.1:8099/jiak"
        And I get the key "test" from the bucket "test" on "http://127.0.0.1:8100/jiak"
        
    Scenario: Setup a three node cluster and bring down a node
        Given I setup and start "node1" on port "8098"
        And I setup and start "node2" on port "8099"
        And I setup and start "node3" on port "8100"
        And I join "node2" to "node1"
        And I join "node3" to "node1"
        And I set bucket schema "test" to '{}' on "http://127.0.0.1:8098/jiak"
        And I put '{"bucket":"test", "key":"test", "object":{}, "links":[]}' in "http://127.0.0.1:8098/jiak"
        When I stop the node "node1"
        Then I get the key "test" from the bucket "test" on "http://127.0.0.1:8099/jiak"
        And I get the key "test" from the bucket "test" on "http://127.0.0.1:8100/jiak"