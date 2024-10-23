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

# Uncomment for debugging
#echo $ACCESS_TOKEN
#curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" https://localhost:8090/security/1.0/activenodes/http

echo "Creating Rolebindings for Group: cp_components"

echo "Give DeveloperRead and DeveloperWrite to _confluent-command license topic"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"_confluent-command\",\"patternType\":\"LITERAL\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:cp_components/roles/DeveloperRead/bindings

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"_confluent-command\",\"patternType\":\"LITERAL\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:cp_components/roles/DeveloperWrite/bindings

# create Rolebindings for SR
echo "Creating Rolebindings for Group: cp_components/schemaregistry_apps"
echo "Give SecurityAdmin to schema-registry cluster"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:schemaregistry_apps/roles/SecurityAdmin

echo "Give ResourceOwner to _schemas, _schema_encoders, _exporter_states, _exporter_configs topic, and schema-registry group"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"_schemas\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Topic\",\"name\":\"_schema_encoders\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Topic\",\"name\":\"_exporter_configs\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Topic\",\"name\":\"_exporter_states\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Group\",\"name\":\"schema-registry\",\"patternType\":\"LITERAL\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:schemaregistry_apps/roles/ResourceOwner/bindings

# add rolebinding to create subjects
echo "Give ResourceOwner to create subjects with test prefix for User: schemaregistryclient"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}},\"resourcePatterns\":[{\"resourceType\":\"Subject\",\"name\":\"test\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/User:schemaregistryclient/roles/ResourceOwner/bindings

# create Rolebindings for Connect
echo "Creating Rolebindings for Group: cp_components/connect_apps"
echo "Give SecurityAdmin to Group: connect_apps for connect cluster"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:connect_apps/roles/SecurityAdmin

echo "Give ResourceOwner for connect-offsets, connect-statuses, connect-configs, _confluent-secrets topic, and to group connect-cluster, and secret-registry"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"connect-offsets\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Topic\",\"name\":\"connect-configs\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Topic\",\"name\":\"connect-statuses\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Topic\",\"name\":\"_confluent-secrets\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Group\",\"name\":\"connect-cluster\",\"patternType\":\"LITERAL\"},{\"resourceType\":\"Group\",\"name\":\"secret-registry\",\"patternType\":\"LITERAL\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:connect_apps/roles/ResourceOwner/bindings

# add rolebinding to create connectors
echo "Give ResourceOwner to User: connectclient for Connectors with connector Prefix"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}},\"resourcePatterns\":[{\"resourceType\":\"Connector\",\"name\":\"connector\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/User:connectclient/roles/ResourceOwner/bindings

echo "Give ResourceOwner to User: connectclient for Topics with connector Prefix and Groups with connector Prefix"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"connector\",\"patternType\":\"PREFIXED\"},{\"resourceType\":\"Group\",\"name\":\"connector\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/User:connectclient/roles/ResourceOwner/bindings

echo "Give ResourceOwner to User: connectclient for Subjects with connector Prefix"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}},\"resourcePatterns\":[{\"resourceType\":\"Subject\",\"name\":\"connector\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/User:connectclient/roles/ResourceOwner/bindings

#echo "Creating Rolebindings for User: connectorsinkclient"
#echo "Creating Rolebindings for User: connectorsourceclient"
#echo "Creating Rolebindings for User: replicatorclient"
# Create rolebindings for kafkarestproxy
echo "Creating Rolebindings for Group: cp_components/restproxy_apps for kafkarestproxy prefix topic and group"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"kafkarestproxy\",\"patternType\":\"PREFIXED\"},{\"resourceType\":\"Group\",\"name\":\"kafkarestproxy\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:restproxy_apps/roles/ResourceOwner/bindings

# Create rolebindings for controlcenterclient
echo "Creating Rolebindings for Group: cp_components/controlcenter_apps"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:controlcenter_apps/roles/SystemAdmin

# pretty sure this is not needed
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:controlcenter_apps/roles/SecurityAdmin

# Create rolebindings for kafkacliclient
echo "Creating Rolebindings for User: kafkaclient"
echo "Give ResourceOwner to kafkacli Topic prefix and Group"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"kafkacli\",\"patternType\":\"PREFIXED\"},{\"resourceType\":\"Group\",\"name\":\"kafkacli\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/User:kafkacliclient/roles/ResourceOwner/bindings

echo "Give ResourceOwner to kafkacli Subject prefix"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}},\"resourcePatterns\":[{\"resourceType\":\"Subject\",\"name\":\"kafkacli\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/User:kafkacliclient/roles/ResourceOwner/bindings

#echo "Creating Rolebindings for User: kafkarestclient"

# User rolebindings
echo "Creating Rolebindings for User Group Auditors"
echo "Give DeveloperRead to Group: auditors"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"*\",\"patternType\":\"LITERAL\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:auditors/roles/DeveloperRead/bindings

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}},\"resourcePatterns\":[{\"resourceType\":\"Subject\",\"name\":\"*\",\"patternType\":\"LITERAL\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:auditors/roles/DeveloperRead/bindings

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}},\"resourcePatterns\":[{\"resourceType\":\"Connector\",\"name\":\"*\",\"patternType\":\"LITERAL\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:auditors/roles/DeveloperRead/bindings


#echo "Creating Rolebindings for User Group Employees"

echo "Creating Rolebindings for User Group Operators"
echo "Give ClusterAdmin to Group: operators"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:operators/roles/ClusterAdmin

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:operators/roles/ClusterAdmin

echo "Creating Rolebindings for User Group Developers"
echo "Give UserAdmin to Group: developers"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:developers/roles/UserAdmin

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:developers/roles/UserAdmin

echo "Creating Rolebindings for User Group Developers/billing"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"billing\",\"patternType\":\"PREFIXED\"},{\"resourceType\":\"Group\",\"name\":\"billing\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:billing/roles/ResourceOwner/bindings

echo "Creating Rolebindings for User Group Developers/iot"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"iot\",\"patternType\":\"PREFIXED\"},{\"resourceType\":\"Group\",\"name\":\"iot\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:iot/roles/ResourceOwner/bindings

echo "Creating Rolebindings for User Group Developers/notifications"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"notifications\",\"patternType\":\"PREFIXED\"},{\"resourceType\":\"Group\",\"name\":\"notifications\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:notifications/roles/ResourceOwner/bindings

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}},\"resourcePatterns\":[{\"resourceType\":\"Subject\",\"name\":\"notifications\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:notifications/roles/ResourceOwner/bindings

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}},\"resourcePatterns\":[{\"resourceType\":\"Connector\",\"name\":\"notifications\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:notifications/roles/ResourceOwner/bindings

echo "Creating Rolebindings for User Group Developers/purchasing"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"scope\":{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}},\"resourcePatterns\":[{\"resourceType\":\"Topic\",\"name\":\"purchasing\",\"patternType\":\"PREFIXED\"},{\"resourceType\":\"Group\",\"name\":\"purchasing\",\"patternType\":\"PREFIXED\"}]}" \
    ${MDS_HOST}/security/1.0/principals/Group:purchasing/roles/ResourceOwner/bindings

echo "Create Rolebindings for User Group administrators"
curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:administrators/roles/SystemAdmin

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"schema-registry-cluster\":\"schema-registry\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:administrators/roles/SystemAdmin

curl -k -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -X POST \
    -H "Content-Type: application/json" \
    --data "{\"clusters\":{\"kafka-cluster\":\"${CLUSTER_ID}\",\"connect-cluster\":\"connect-cluster\"}}" \
    ${MDS_HOST}/security/1.0/principals/Group:administrators/roles/SystemAdmin
