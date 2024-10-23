#!/bin/bash
# OPENSSL_BIN=openssl GEN_DIR=files ./create-mds-keypair.sh

if [ -z "$OPENSSL_BIN" ]; then
    OPENSSL_BIN=openssl
fi

if [ -z "$(which $OPENSSL_BIN)" ]; then
    echo "Missing openssl, please install"
    exit 1
fi

OPENSSL_VERSION=$($OPENSSL_BIN version | awk '{print $2}' | tr -d '.' | cut -c -3)

if [[ $OPENSSL_VERSION -gt 309 ]]; then
    echo "OpenSSL version is greater than or equal to 3.1.0, please use 3.0 versions only"
    exit 1
fi

MDS_KEYPAIR_PATH=$GEN_DIR/files/keypair
MDS_PRIVATE_KEY=$MDS_KEYPAIR_PATH/mds-keypair-private.pem
MDS_PUBLIC_KEY=$MDS_KEYPAIR_PATH/mds-keypair-public.pem

mkdir -p $MDS_KEYPAIR_PATH

# Generate Private Key
$OPENSSL_BIN genrsa -out $MDS_PRIVATE_KEY 2048
# Extract Public Key
$OPENSSL_BIN rsa -in $MDS_PRIVATE_KEY -outform PEM -pubout -out $MDS_PUBLIC_KEY
