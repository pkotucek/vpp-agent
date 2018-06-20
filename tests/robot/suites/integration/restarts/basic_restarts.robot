*** Settings ***
Resource    ../../../libraries/kubernetes/Restarts_Setup.robot
Resource    ../../../libraries/kubernetes/KubeTestOperations.robot

Resource     ../../../variables/${VARIABLES}_variables.robot

Library    SSHLibrary

Suite Setup       Basic Restarts Setup with ${1} VNFs and ${1} non-VPP containers
Suite Teardown    Basic Restarts Teardown
Test Setup        Ping Until Success - Unix Ping    ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
Test Teardown     Recreate Topology If Test Failed

Documentation    Test suite for Kubernetes pod restarts using a single VNF pod
...    and a single non-VPP pod.
...
...    Restart performed through kubernetes pod deletion and through
...    segmentation fault signal sent to VPP.
...
...    Connectivity verified using "ping" command to and from the VNF
...    and non-VPP containers.

*** Variables ***
${VARIABLES}=       common
${ENV}=             common
${CLUSTER_ID}=      INTEGRATION1
${vnf0_ip}=         192.168.5.1
${novpp0_ip}=       192.168.5.2
@{novpp_pods}=      novpp-0
@{vnf_pods}=        vnf-vpp-0

*** Test Cases ***
Basic restart scenario - VNF
    [Documentation]    Restart VNF node, ping it's IP address from the non-VPP
    ...    node until a reply is received, then verify connectivity both ways.

    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    vnf-vpp-0
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

    Trigger Pod Restart - VPP SIGSEGV        ${vnf_pods[0]}
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

Basic restart scenario - noVPP
    [Documentation]    Restart non-VPP node, ping it's IP address from the VNF
    ...    node until a reply is received, then verify connectivity both ways.

    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    novpp-0
    Ping Until Success - VPP Ping            ${vnf_pods[0]}           ${novpp0_ip}    timeout=120s
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}           ${novpp0_ip}
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}         ${vnf0_ip}

Basic restart scenario - VSwitch
    [Documentation]    Restart the vswitch, ping the VNF's IP address from
    ...    the non-VPP node until a reply is received, then verify connectivity
    ...    both ways.

    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    ${vswitch_pod_name}    vswitch=${TRUE}
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

    Trigger Pod Restart - VPP SIGSEGV        ${vswitch_pod_name}
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

Basic Restart Scenario - VSwitch and VNF
    [Documentation]    Restart vswitch and VNF, ping the VNF's IP address from
    ...    the non-VPP node until a reply is received, then verify connectivity
    ...    both ways.

    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    vnf-vpp-0
    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    ${vswitch_pod_name}    vswitch=${TRUE}
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

    Trigger Pod Restart - VPP SIGSEGV        ${vnf_pods[0]}
    Trigger Pod Restart - VPP SIGSEGV        ${vswitch_pod_name}
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

Basic Restart Scenario - VSwitch and noVPP
    [Documentation]    Restart vswitch and non-VPP pod, ping the non-VPP
    ...    pod's IP address from the VNF node until a reply is received, then
    ...    verify connectivity both ways.

    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    novpp-0
    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    ${vswitch_pod_name}    vswitch=${TRUE}
    Ping Until Success - VPP Ping            ${vnf_pods[0]}           ${novpp0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    novpp-0
    Trigger Pod Restart - VPP SIGSEGV        ${vswitch_pod_name}
    Ping Until Success - VPP Ping            ${vnf_pods[0]}           ${novpp0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

Basic Restart Scenario - VSwitch, noVPP and VNF
    [Documentation]    Restart vswitch, VNF and non-VPP pod, ping the non-VPP
    ...    pod's IP address from the VNF node until a reply is received, then
    ...    verify connectivity both ways.

    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    vnf-vpp-0
    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    novpp-0
    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    ${vswitch_pod_name}    vswitch=${TRUE}
    Ping Until Success - VPP Ping            ${vnf_pods[0]}           ${novpp0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

    Trigger Pod Restart - VPP SIGSEGV        ${vnf_pods[0]}
    Trigger Pod Restart - Pod Deletion       ${testbed_connection}    novpp-0
    Trigger Pod Restart - VPP SIGSEGV        ${vswitch_pod_name}
    Ping Until Success - VPP Ping            ${vnf_pods[0]}           ${novpp0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

Basic Restart Scenario - full topology (startup sequence: etcd-vswitch-pods-sfc)
    [Documentation]    Restart the full topology, then bring it back up in the
    ...    specified sequence and verify connectivity between VNF and non-VPP
    ...    pods.
    Restart Topology With Startup Sequence    etcd    vswitch    vnf    novpp    sfc
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

Basic Restart Scenario - full topology (startup sequence: etcd-vswitch-sfc-pods)
    [Documentation]    Restart the full topology, then bring it back up in the
    ...    specified sequence and verify connectivity between VNF and non-VPP
    ...    pods.
    Restart Topology With Startup Sequence    etcd    vswitch    sfc    vnf    novpp
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

Basic Restart Scenario - full topology (startup sequence: etcd-sfc-vswitch-pods)
    [Documentation]    Restart the full topology, then bring it back up in the
    ...    specified sequence and verify connectivity between VNF and non-VPP
    ...    pods.
    Restart Topology With Startup Sequence    etcd    sfc    vswitch    vnf    novpp
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

Basic Restart Scenario - full topology (startup sequence: etcd-sfc-pods-vswitch)
    [Documentation]    Restart the full topology, then bring it back up in the
    ...    specified sequence and verify connectivity between VNF and non-VPP
    ...    pods.
    Restart Topology With Startup Sequence    etcd    sfc    vnf    novpp    vswitch
    Ping Until Success - Unix Ping           ${novpp_pods[0]}    ${vnf0_ip}    timeout=120s
    Verify Pod Connectivity - Unix Ping      ${novpp_pods[0]}    ${vnf0_ip}
    Verify Pod Connectivity - VPP Ping       ${vnf_pods[0]}      ${novpp0_ip}

#TODO: 4 memifs per VNF
#TODO: repeat test case execution X times
#TODO: verify connectivity with traffic (iperf,tcpkali,...) longer than memif ring size
#TODO: scale up to 16 VNFs and 50 non-VPP containers.
#TODO: measure pod restart time

*** Keywords ***
Recreate Topology If Test Failed
    [Documentation]    After a failed test, delete the kubernetes topology
    ...    and create it again.
    BuiltIn.Run Keyword If Test Failed    Run Keywords
    ...    Cleanup_Basic_Restarts_Deployment_On_Cluster    ${testbed_connection}
    ...    AND    Basic Restarts Setup with ${1} VNFs and ${1} non-VPP containers