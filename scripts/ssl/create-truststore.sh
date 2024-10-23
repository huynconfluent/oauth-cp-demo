#!/bin/bash

# ./create-truststore.sh <component_name> <fullchain_cert> <truststore_password> <truststore_path>

if [ -z "$(which openssl)" ]; then
    echo "Missing openssl, please install"
    exit 1
fi

if [ -z "$(which keytool)" ]; then
    echo "Missing keytool, please install"
    exit 1
fi

COMPONENT_NAME=$1
CERTFILE=$2
TRUSTSTORE_PASSWORD=$3
TRUSTSTORE_PATH=$4
TRUSTSTORE_FILE="$TRUSTSTORE_PATH/$COMPONENT_NAME.truststore.jks"
CERT_ALIAS="caroot"

mkdir -p "$TRUSTSTORE_PATH"
#echo "Creating Truststore for $COMPONENT_NAME..."
keytool -noprompt -keystore $TRUSTSTORE_FILE -alias $CERT_ALIAS -import -file $CERTFILE -storepass $TRUSTSTORE_PASSWORD -keypass $TRUSTSTORE_PASSWORD
