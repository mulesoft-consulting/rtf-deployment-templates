#!/bin/bash

mkdir -p /opt/anypoint/runtimefabric
cat >> /opt/anypoint/runtimefabric/env <<EOF
RTF_NODE_ROLE=dedicated_ingress_node
RTF_INSTALL_ROLE=joiner
RTF_DOCKER_DEVICE_SIZE=50G
RTF_TOKEN="${cluster_token}"
RTF_INSTALLER_IP="${installer_ip}"
EOF
