#!/bin/sh

source ../../scripts/helper/functions.sh

# set cp version
source ../../scripts/helper/env.sh
echo "Setting CP_VERSION=$CP_VERSION"
echo ""

if [ -z "$BASE_DIR" ]; then
    echo "Please set BASE_DIR=\$(pwd)"
    exit 1
fi

echo "Create data directories for kraft and kafka..."
mkdir -p "$BASE_DIR/../../generated/kraft/data"
mkdir -p "$BASE_DIR/../../generated/kafka/data"

# start keycloak
echo "Starting keycloak..."
docker-compose up -d keycloak
echo "waiting 30 seconds for keycloak to be ready..."
sleep 30
echo ""

# start controller + broker
echo "Starting Kraft Controller and Kafka Broker..."
docker-compose up -d kraftcontroller kafka
echo ""

# wait for kafka to be up
MAX_WAIT=240
echo -e "\nWaiting on $MAX_WAIT seconds for kafka to be ready..."
retry $MAX_WAIT check_container_up kafka || exit 1
echo ""

echo "Create Rolebindings..."
source ../../scripts/helper/create-rb.sh

# Start csc and download datagen connector
docker-compose up -d tools
sleep 5
mkdir -p "$BASE_DIR/../../generated/connect/connectors"

if [[ $(find $BASE_DIR/../../generated/connect/connectors/confluentinc-kafka-connect-datagen/lib -type f -iname 'kafka-connect-datagen*' | wc -l) -ge 1 ]]; then
    echo "Skipping Datagen Source Connector download..."
else
    echo "Downoading Datagen Source Connector..."
    docker exec -ti tools confluent-hub install --no-prompt --component-dir /generated/connect/connectors --worker-configs /tmp/connect.properties confluentinc/kafka-connect-datagen:latest
fi
echo ""

# start schemaregistry + connect + restproxy
echo "Starting Schema Registry and Connect and Rest Proxy..."
docker-compose up -d connect schemaregistry restproxy

# wait for schemaregistry to be up
#MAX_WAIT=240
#echo -e "\nWaiting on $MAX_WAIT seconds for schemaregistry to be ready..."
#retry $MAX_WAIT check_container_up schemaregistry || exit 1
#echo ""

# wait for connect to be up
MAX_WAIT=240
echo -e "\nWaiting on $MAX_WAIT seconds for connect to be ready..."
retry $MAX_WAIT check_container_up connect || exit 1
echo ""

# start controlcenter
docker-compose up -d controlcenter

# wait for controlcenter to be up
MAX_WAIT=240
echo -e "\nWaiting on $MAX_WAIT seconds for controlcenter to be ready..."
retry $MAX_WAIT check_container_up controlcenter || exit 1
echo ""

echo "Demo is now ready!!"

