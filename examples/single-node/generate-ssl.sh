#!/bin/sh

if [ -z "$BASE_DIR" ]; then
    echo "Please export BASE_DIR=\$(pwd)"
    exit 1
fi

# Generate SSL files
CERT_CHAIN=1
BASE_SUBJECT="/C=US/ST=CA/O=Confluent Demo"
ORG_UNIT="OU=Global Technical Support"
GENERATED_DIR="$BASE_DIR/../../generated/ssl"
KEYSTORE_PASSWORD="topsecret"

echo "Creating SSL Certificates..."
# Generating Root CA
export WORK_DIR=$GENERATED_DIR/root_ca
source $BASE_DIR/../../scripts/ssl/create-ca.sh $BASE_DIR/../../scripts/ssl/configs/root_ca.cnf "$BASE_SUBJECT/CN=Root X1"

# Generating Intermediate CA
export WORK_DIR=$GENERATED_DIR/intermediate_ca
source $BASE_DIR/../../scripts/ssl/create-intermediate-ca.sh $CERT_CHAIN "$BASE_SUBJECT/$ORG_UNIT/CN=Intermediate" $BASE_DIR/../../scripts/ssl/configs/intermediate_ca.cnf $GENERATED_DIR/root_ca/private/ca.key $GENERATED_DIR/root_ca/certs/ca.pem

# Generating Component Certs
export WORK_DIR=$GENERATED_DIR/component GEN_DIR=$GENERATED_DIR/files
source $BASE_DIR/../../scripts/ssl/create-user-cert.sh "keycloak" "$BASE_SUBJECT/$ORG_UNIT" "$BASE_DIR/../../scripts/ssl/configs/component.cnf" \
    "$GENERATED_DIR/intermediate_ca/private/intermediate_$CERT_CHAIN.key" "$GENERATED_DIR/intermediate_ca/certs/intermediate-signed_$CERT_CHAIN.pem" \
    "$GENERATED_DIR/intermediate_ca/certs/fullchain.pem" "DNS:localhost,DNS:keycloak"
source $BASE_DIR/../../scripts/ssl/create-truststore.sh "keycloak" "$GENERATED_DIR/root_ca/certs/ca.pem" "$KEYSTORE_PASSWORD" "$GENERATED_DIR/files"

source $BASE_DIR/../../scripts/ssl/create-user-cert.sh "kraftcontroller" "$BASE_SUBJECT/$ORG_UNIT" "$BASE_DIR/../../scripts/ssl/configs/component.cnf" \
    "$GENERATED_DIR/intermediate_ca/private/intermediate_$CERT_CHAIN.key" "$GENERATED_DIR/intermediate_ca/certs/intermediate-signed_$CERT_CHAIN.pem" \
    "$GENERATED_DIR/intermediate_ca/certs/fullchain.pem" "DNS:localhost,DNS:kraftcontroller,DNS:kraftcontroller.confluentdemo.io"
source $BASE_DIR/../../scripts/ssl/create-truststore.sh "kraftcontroller" "$GENERATED_DIR/root_ca/certs/ca.pem" "$KEYSTORE_PASSWORD" "$GENERATED_DIR/files"

source $BASE_DIR/../../scripts/ssl/create-user-cert.sh "kafka" "$BASE_SUBJECT/$ORG_UNIT" "$BASE_DIR/../../scripts/ssl/configs/component.cnf" \
    "$GENERATED_DIR/intermediate_ca/private/intermediate_$CERT_CHAIN.key" "$GENERATED_DIR/intermediate_ca/certs/intermediate-signed_$CERT_CHAIN.pem" \
    "$GENERATED_DIR/intermediate_ca/certs/fullchain.pem" "DNS:localhost,DNS:kafka,DNS:kafka.confluentdemo.io"
source $BASE_DIR/../../scripts/ssl/create-truststore.sh "kafka" "$GENERATED_DIR/root_ca/certs/ca.pem" "$KEYSTORE_PASSWORD" "$GENERATED_DIR/files"

source $BASE_DIR/../../scripts/ssl/create-user-cert.sh "schemaregistry" "$BASE_SUBJECT/$ORG_UNIT" "$BASE_DIR/../../scripts/ssl/configs/component.cnf" \
    "$GENERATED_DIR/intermediate_ca/private/intermediate_$CERT_CHAIN.key" "$GENERATED_DIR/intermediate_ca/certs/intermediate-signed_$CERT_CHAIN.pem" \
    "$GENERATED_DIR/intermediate_ca/certs/fullchain.pem" "DNS:localhost,DNS:schemaregistry,DNS:schemaregistry.confluentdemo.io"
source $BASE_DIR/../../scripts/ssl/create-truststore.sh "schemaregistry" "$GENERATED_DIR/root_ca/certs/ca.pem" "$KEYSTORE_PASSWORD" "$GENERATED_DIR/files"

source $BASE_DIR/../../scripts/ssl/create-user-cert.sh "connect" "$BASE_SUBJECT/$ORG_UNIT" "$BASE_DIR/../../scripts/ssl/configs/component.cnf" \
    "$GENERATED_DIR/intermediate_ca/private/intermediate_$CERT_CHAIN.key" "$GENERATED_DIR/intermediate_ca/certs/intermediate-signed_$CERT_CHAIN.pem" \
    "$GENERATED_DIR/intermediate_ca/certs/fullchain.pem" "DNS:localhost,DNS:connect,DNS:connect.confluentdemo.io"
source $BASE_DIR/../../scripts/ssl/create-truststore.sh "connect" "$GENERATED_DIR/root_ca/certs/ca.pem" "$KEYSTORE_PASSWORD" "$GENERATED_DIR/files"

source $BASE_DIR/../../scripts/ssl/create-user-cert.sh "restproxy" "$BASE_SUBJECT/$ORG_UNIT" "$BASE_DIR/../../scripts/ssl/configs/component.cnf" \
    "$GENERATED_DIR/intermediate_ca/private/intermediate_$CERT_CHAIN.key" "$GENERATED_DIR/intermediate_ca/certs/intermediate-signed_$CERT_CHAIN.pem" \
    "$GENERATED_DIR/intermediate_ca/certs/fullchain.pem" "DNS:localhost,DNS:restproxy,DNS:restproxy.confluentdemo.io"
source $BASE_DIR/../../scripts/ssl/create-truststore.sh "restproxy" "$GENERATED_DIR/root_ca/certs/ca.pem" "$KEYSTORE_PASSWORD" "$GENERATED_DIR/files"

source $BASE_DIR/../../scripts/ssl/create-user-cert.sh "controlcenter" "$BASE_SUBJECT/$ORG_UNIT" "$BASE_DIR/../../scripts/ssl/configs/component.cnf" \
    "$GENERATED_DIR/intermediate_ca/private/intermediate_$CERT_CHAIN.key" "$GENERATED_DIR/intermediate_ca/certs/intermediate-signed_$CERT_CHAIN.pem" \
    "$GENERATED_DIR/intermediate_ca/certs/fullchain.pem" "DNS:localhost,DNS:controlcenter,DNS:controlcenter.confluentdemo.io"
source $BASE_DIR/../../scripts/ssl/create-truststore.sh "controlcenter" "$GENERATED_DIR/root_ca/certs/ca.pem" "$KEYSTORE_PASSWORD" "$GENERATED_DIR/files"

source $BASE_DIR/../../scripts/ssl/create-user-cert.sh "kafkacliclient" "$BASE_SUBJECT/$ORG_UNIT" "$BASE_DIR/../../scripts/ssl/configs/component.cnf" \
    "$GENERATED_DIR/intermediate_ca/private/intermediate_$CERT_CHAIN.key" "$GENERATED_DIR/intermediate_ca/certs/intermediate-signed_$CERT_CHAIN.pem" \
    "$GENERATED_DIR/intermediate_ca/certs/fullchain.pem" "DNS:localhost,DNS:kafkacliclient,DNS:kafkacliclient.confluentdemo.io"
source $BASE_DIR/../../scripts/ssl/create-truststore.sh "kafkacliclient" "$GENERATED_DIR/root_ca/certs/ca.pem" "$KEYSTORE_PASSWORD" "$GENERATED_DIR/files"

echo "SSL Certificate Generation complete!"

echo ""

echo "Generating MDS keypair..."
export GEN_DIR=$BASE_DIR/../../generated/ssl
source $BASE_DIR/../../scripts/ssl/create-mds-keypair.sh
