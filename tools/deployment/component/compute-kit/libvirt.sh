#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -xe

export OS_CLOUD=openstack_helm
CEPH_ENABLED=false
if openstack service list -f value -c Type | grep -q "^volume" && \
    openstack volume type list -f value -c Name | grep -q "rbd"; then
  CEPH_ENABLED=true
fi

#NOTE: Get the over-rides to use
export HELM_CHART_ROOT_PATH="${HELM_CHART_ROOT_PATH:="${OSH_INFRA_PATH:="../openstack-helm-infra"}"}"
: ${OSH_EXTRA_HELM_ARGS_LIBVIRT:="$(helm osh get-values-overrides -p ${HELM_CHART_ROOT_PATH} -c libvirt ${FEATURES})"}

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}
helm upgrade --install libvirt ${HELM_CHART_ROOT_PATH}/libvirt \
  --namespace=openstack \
  --set conf.ceph.enabled=${CEPH_ENABLED} \
  ${OSH_EXTRA_HELM_ARGS:=} \
  ${OSH_EXTRA_HELM_ARGS_LIBVIRT}

#NOTE: DO NOT wait for pods are ready, because libvirt depends
# on neutron ovs agent pods or ovn controller pods
