#!/bin/bash

mkdir -p /opt/anypoint/runtimefabric
cat >> /opt/anypoint/runtimefabric/env <<EOF
RTF_NODE_ROLE=controller_node
RTF_INSTALL_ROLE=joiner
RTF_ETCD_DEVICE_SIZE=60G
RTF_DOCKER_DEVICE_SIZE=250G
RTF_TOKEN="${cluster_token}"
RTF_INSTALLER_IP="${installer_ip}"
RTF_HTTP_PROXY='${http_proxy}'
RTF_NO_PROXY='${no_proxy}'
RTF_MONITORING_PROXY='${monitoring_proxy}'
RTF_SERVICE_UID='${service_uid}'
RTF_SERVICE_GID='${service_gid}'
EOF
