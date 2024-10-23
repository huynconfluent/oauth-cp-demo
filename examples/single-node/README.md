# Getting Started

This is a basic demo example of OAUTH/OIDC configuration within Confluent Platform 7.7.0+

## Prerequisites

It'll be helpful to ensure you have the following set in your `/etc/hosts` file

```
127.0.0.1 keycloak kraftcontroller kafka schemaregistry connect controlcenter restproxy
```

### Export the `BASE_DIR` and `OPENSSL_BIN` as needed

```
export BASE_DIR=$(pwd)
```

## Using Confluent CLI tools

### Obtain JWT via cURL

You can obtain a JWT via curl by supply `clientId` and `clientSecret` to the IDP's Token Endpoint

```
curl -k -H "Content-Type: application/x-www-form-urlencoded" \
-H "client_id=kafkacliclient" \
-H "client_secret=kafkacliclient-secret" \
-H "grant_type=client_credentials" \
https://keycloak:8443/realms/confluentdemo/protocol/openid-connect/token
```

If you do not want to provide username and password in the command you can potentially pass a base64 encoded value to authenticate

```
echo -n "kafkacliclient:kafkacliclient-secret" | base64
a2Fma2FjbGljbGllbnQ6a2Fma2FjbGljbGllbnQtc2VjcmV0
curl -X POST -k -H "Authorization: Basic a2Fma2FjbGljbGllbnQ6a2Fma2FjbGljbGllbnQtc2VjcmV0" \
-H "Content-Type: application/x-www-form-urlencoded" \
-d "grant_type=client_credentials"
-k https://keycloak:8443/realms/confluentdemo/protocol/openid-connect/token
```

In both cases it will provide you with an access_token, which you can then pass to MDS/REST

```
curl -k -H "Authorization: Bearer JWT_TOKEN" \
https://kafka:8090/security/1.0/roles
```

The above will list available roles. You can also run something like the following to get information on the kafka cluster.

```
curl -k -H "Authorization: Bearer JWT_TOKEN" \
https://kafka:8090/kafka/v3/clusters
```

In either scenario receiving resource information back would indicate a successful Authorization.

### Using kafka-topics

Exec into the Kafka Container

```
docker exec -ti kafka bash
```

Then run

```
kafka-topics --bootstrap-server kafka:9094 --command-config /tmp/client-properties/oauth-cli.properties --list
```

The above command is using our `oauth-cli.properties` which has the following configuration

```
group.id=kafkacli-test-consumer-group
sasl.mechanism=OAUTHBEARER
security.protocol=SASL_SSL
ssl.truststore.location=/ssl/kafkacliclient.truststore.jks
ssl.truststore.password=topsecret
ssl.endpoint.identification.algorithm=
sasl.login.callback.handler.class=org.apache.kafka.common.security.oauthbearer.secured.OAuthBearerLoginCallbackHandler
sasl.login.connect.timeout.ms=15000
sasl.oauthbearer.token.endpoint.url=https://keycloak:8443/realms/confluentdemo/protocol/openid-connect/token
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required \
        ssl.truststore.location="/ssl/kafkacliclient.truststore.jks" \
        ssl.truststore.password="topsecret" \
        clientId="kafkacliclient" \
        clientSecret="kafkacliclient-secret";
```

Now there's no topics viewable by this role, so let's go ahead and create something and produce to said topic

```
kafka-topics --bootstrap-server kafka:9094 --command-config /tmp/client-properties/oauth-cli.properties --create --topic kafkacli-test-topic --partitions 1 --replication-factor 1

kafka-console-producer --bootstrap-server kafka:9094 --producer.config /tmp/client-properties/oauth-cli.properties --topic kafkacli-test-topic
```

