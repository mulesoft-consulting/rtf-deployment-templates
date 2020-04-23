#!/bin/bash

mkdir -p /opt/anypoint/runtimefabric
cat >> /opt/anypoint/runtimefabric/env <<EOF
RTF_NODE_ROLE=controller_node
RTF_INSTALL_ROLE=leader
RTF_INSTALL_PACKAGE_URL="${installer_url}"
RTF_ETCD_DEVICE_SIZE=60G
RTF_DOCKER_DEVICE_SIZE=250G
RTF_TOKEN="${cluster_token}"
RTF_NAME="${cluster_name}"
RTF_ACTIVATION_DATA="${activation_data}"
RTF_ORG_ID="${org_id}"
RTF_REGION="${region}"
RTF_ENDPOINT="${endpoint}"
RTF_AUTH_TOKEN="${auth_token}"
RTF_MULE_LICENSE='${mule_license}'
RTF_HTTP_PROXY='${http_proxy}'
RTF_NO_PROXY='${no_proxy}'
RTF_MONITORING_PROXY='${monitoring_proxy}'
RTF_SERVICE_UID='${service_uid}'
RTF_SERVICE_GID='${service_gid}'
RTF_AGENT_URL='${agent_url}'
POD_NETWORK_CIDR='${pod_network_cidr_block}'
SERVICE_CIDR='${service_cidr_block}'
EOF
