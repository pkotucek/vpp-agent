*** Settings ***

Library     OperatingSystem
Library     String
#Library     RequestsLibrary

Resource     ../../variables/${VARIABLES}_variables.robot
Resource    ../../libraries/all_libs.robot
Resource    ../../libraries/pretty_keywords.robot

Suite Setup       Run Keywords    Discard old results

*** Variables ***
${VARIABLES}=          common
${ENV}=                common

*** Test Cases ***
# CRUD tests for routing
Add Route, Then Delete Route And Again Add Route For Default VRF
    [Setup]      Test Setup
    [Teardown]   Test Teardown

    Given Add Agent VPP Node                 agent_vpp_1
    Then IP Fib On agent_vpp_1 Should Not Contain Route With IP 10.1.1.0/24
    Then Create Route On agent_vpp_1 With IP 10.1.1.0/24 With Next Hop 192.168.1.1 And Vrf Id 0
    Then Show Interfaces On agent_vpp_1
    Then IP Fib On agent_vpp_1 Should Contain Route With IP 10.1.1.0/24
    Then Delete Routes On agent_vpp_1 And Vrf Id 0
    Then IP Fib On agent_vpp_1 Should Not Contain Route With IP 10.1.1.0/24
    Then Create Route On agent_vpp_1 With IP 10.1.1.0/24 With Next Hop 192.168.1.1 And Vrf Id 0

Add Route, Then Delete Route And Again Add Route For Non Default VRF
    [Setup]      Test Setup
    [Teardown]   Test Teardown

    Given Add Agent VPP Node                 agent_vpp_1
    Then IP Fib On agent_vpp_1 Should Not Contain Route With IP 10.1.1.0/24
    Then Create Route On agent_vpp_1 With IP 10.1.1.0/24 With Next Hop 192.168.1.1 And Vrf Id 2
    Then Show Interfaces On agent_vpp_1
    Then IP Fib On agent_vpp_1 Should Contain Route With IP 10.1.1.0/24
    Then IP Fib Table 0 On agent_vpp_1 Should Not Contain Route With IP 10.1.1.0/24
    Then IP Fib Table 2 On agent_vpp_1 Should Contain Route With IP 10.1.1.0/24
    Then Delete Routes On agent_vpp_1 And Vrf Id 2
    Then IP Fib On agent_vpp_1 Should Not Contain Route With IP 10.1.1.0/24
    Then IP Fib Table 2 On agent_vpp_1 Should Not Contain Route With IP 10.1.1.0/24
    Then Create Route On agent_vpp_1 With IP 10.1.1.0/24 With Next Hop 192.168.1.1 And Vrf Id 2
    Then IP Fib On agent_vpp_1 Should Contain Route With IP 10.1.1.0/24
    Then IP Fib Table 0 On agent_vpp_1 Should Not Contain Route With IP 10.1.1.0/24
    Then IP Fib Table 2 On agent_vpp_1 Should Contain Route With IP 10.1.1.0/24

# CRUD tests for VRF - automatically added with creating of interface - delete is not implemented
Add VRF Table In Background While Creating Interface Memif
    [Setup]      Test Setup
    [Teardown]   Test Teardown

    Given Add Agent VPP Node                 agent_vpp_1
    # create memif interface in default vrf
    Then Create Master memif0 on agent_vpp_1 with IP 192.168.1.1, MAC 02:f1:be:90:00:00, key 1 and m0.sock socket
    Then Show Interfaces On agent_vpp_1
    Then IP Fib Table 2 On agent_vpp_1 Should Be Empty
    Then IP Fib Table 0 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    # this will transfer interface to newly-in-background-created non default vrf table
    Then Create Master memif0 on agent_vpp_1 with VRF 2, IP 192.168.1.1, MAC 02:f1:be:90:00:00, key 1 and m0.sock socket
    Then IP Fib Table 2 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 0 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # this will transfer interface to other newly-in-background-created non default vrf table
    Then Create Master memif0 on agent_vpp_1 with VRF 1, IP 192.168.1.1, MAC 02:f1:be:90:00:00, key 1 and m0.sock socket
    Then IP Fib Table 1 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 0 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # this will remove non default vrf table in background - N/A
    # Then IP Fib Table 2 On agent_vpp_1 Should Be Empty - N/A
    Then IP Fib Table 2 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # this will transfer interface to existing non default vrf table
    Then Create Master memif0 on agent_vpp_1 with VRF 2, IP 192.168.1.1, MAC 02:f1:be:90:00:00, key 1 and m0.sock socket
    Then IP Fib Table 2 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 0 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 1 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # this will transfer interface to default vrf table
    Then Create Master memif0 on agent_vpp_1 with IP 192.168.1.1, MAC 02:f1:be:90:00:00, key 1 and m0.sock socket
    # 10 nov 2017 this will fail for memif - reason is that Create Master memif0 does not transfer interface to the VRF table 0
    Then IP Fib Table 0 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 1 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # 10 nov 2017 this will fail for memif - reason is that Create Master memif0 does not transfer interface to the VRF table 0
    Then IP Fib Table 2 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32

Add VRF Table In Background While Creating Interface Tap
    [Setup]      Test Setup
    [Teardown]   Test Teardown

    Given Add Agent VPP Node                 agent_vpp_1
    # create Tap interface in default vrf
    Then Create Tap Interface tap0 On agent_vpp_1 With Vrf 0, IP 192.168.1.1, MAC 02:f1:be:90:00:00 And HostIfName linux_tap0
    Then Show Interfaces On agent_vpp_1
    Then IP Fib Table 2 On agent_vpp_1 Should Be Empty
    Then IP Fib Table 0 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    # this will transfer interface to newly-in-background-created non default vrf table
    Then Create Tap Interface tap0 On agent_vpp_1 With Vrf 2, IP 192.168.1.1, MAC 02:f1:be:90:00:00 And HostIfName linux_tap0
    Then IP Fib Table 2 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 0 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # this will transfer interface to other newly-in-background-created non default vrf table
    Then Create Tap Interface tap0 On agent_vpp_1 With Vrf 1, IP 192.168.1.1, MAC 02:f1:be:90:00:00 And HostIfName linux_tap0
    Then IP Fib Table 1 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 0 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # this will remove non default vrf table in background - N/A
    # Then IP Fib Table 2 On agent_vpp_1 Should Be Empty - N/A
    Then IP Fib Table 2 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # this will transfer interface to existing non default vrf table
    Then Create Tap Interface tap0 On agent_vpp_1 With Vrf 2, IP 192.168.1.1, MAC 02:f1:be:90:00:00 And HostIfName linux_tap0
    Then IP Fib Table 2 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 0 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 1 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    # this will transfer interface to default vrf table
    Then Create Tap Interface tap0 On agent_vpp_1 With Vrf 0, IP 192.168.1.1, MAC 02:f1:be:90:00:00 And HostIfName linux_tap0
    Then IP Fib Table 0 On agent_vpp_1 Should Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 1 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32
    Then IP Fib Table 2 On agent_vpp_1 Should Not Contain Route With IP 192.168.1.1/32

*** Keywords ***
IP Fib On ${node} Should Not Contain Route With IP ${ip}/${prefix}
    Log many    ${node}
    ${out}=    vpp_term: Show IP Fib    ${node}
    log many    ${out}
    Should Not Match Regexp    ${out}  ${ip}\\/${prefix}\\s*unicast\\-ip4-chain\\s*\\[\\@0\\]:\\ dpo-load-balance:\\ \\[proto:ip4\\ index:\\d+\\ buckets:\\d+\\ uRPF:\\d+\\ to:\\[0:0\\]\\]

IP Fib On ${node} Should Contain Route With IP ${ip}/${prefix}
    Log many    ${node}
    ${out}=    vpp_term: Show IP Fib    ${node}
    log many    ${out}
    Should Match Regexp        ${out}  ${ip}\\/${prefix}\\s*unicast\\-ip4-chain\\s*\\[\\@0\\]:\\ dpo-load-balance:\\ \\[proto:ip4\\ index:\\d+\\ buckets:\\d+\\ uRPF:\\d+\\ to:\\[0:0\\]\\]