#!/bin/sh

MDS_HOST="https://localhost:8090"
CLUSTER_ID="GKd5IdDpQke_WTFzJzKKnQ"
IDP_HOST="https://keycloak:8443"
IDP_TOKEN_URL="$IDP_HOST/realms/confluentdemo/protocol/openid-connect/token"

# Obtain a JWT and pass that into the following REST calls
ACCESS_TOKEN=$(curl -sSk -H 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'client_id=confluentmetadataservice' \
    --data-urlencode 'client_secret=confluentmetadataservice-secret' \
    --data-urlencode 'grant_type=client_credentials' \
    "${IDP_TOKEN_URL}" | jq -r .access_token)

echo "Viewing Rolebindings for Group:cp_components"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:cp_components/resources | jq

echo "\nViewing Rolebindings for Group:schemaregistry_apps"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:schemaregistry_apps/resources | jq
echo "Schema Registry Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:schemaregistry_apps/resources | jq

echo "\nViewing Rolebindings for User:schemaregistryclient"
echo "Schema Registry Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/User:schemaregistryclient/resources | jq

echo "\nViewing Rolebindings for Group:connect_apps"
echo "Connect Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:connect_apps/resources | jq
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:connect_apps/resources | jq

echo "\nViewing Rolebindings for User:connectclient"
echo "Connect Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/User:connectclient/resources | jq
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/User:connectclient/resources | jq
echo "Schema Registry Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/User:connectclient/resources | jq

echo "\nViewing Rolebindings for Group:restproxy_apps"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:restproxy_apps/resources | jq

echo "\nViewing Rolebindings for Group:controlcenter_apps"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:controlcenter_apps/resources | jq

echo "\nViewing Rolebindings for User:kafkacliclient"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/User:kafkacliclient/resources | jq
echo "Schema Registry Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registrty\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/User:kafkacliclient/resources | jq

echo "\nViewing Rolebindings for Group:auditors"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:auditors/resources | jq
echo "Schema Registry Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:auditors/resources | jq
echo "Connect Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:auditors/resources | jq

echo "\nViewing Rolebindings for Group:operators"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:operators/resources | jq
echo "Schema Registry Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:operators/resources | jq
echo "Connect Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:operators/resources | jq

echo "\nViewing Rolebindings for Group:developers"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:developers/resources | jq
echo "Schema Registry Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:developers/resources | jq
echo "Connect Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:developers/resources | jq

echo "\nViewing Rolebindings for Group:billing"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:billing/resources | jq

echo "\nViewing Rolebindings for Group:iot"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:iot/resources | jq

echo "\nViewing Rolebindings for Group:notifications"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:notifications/resources | jq
echo "Schema Registry Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:notifications/resources | jq
echo "Connect Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:notifications/resources | jq

echo "\nViewing Rolebindings for Group:purchasing"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:purchasing/resources | jq

echo "\nViewing Rolebindings for Group:administrators"
echo "Kafka Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:administrators/resources | jq
echo "Schema Registry Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:administrators/resources | jq
echo "Connect Cluster Roles"
curl -sk -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/lookup/principal/Group:administrators/resources | jq
