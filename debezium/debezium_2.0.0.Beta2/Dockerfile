FROM debezium/connect:2.0.0.Beta2

USER root
RUN microdnf install -y perl openssl wget && microdnf clean all
COPY debezium/debezium_2.0.0.Beta2/preinstall.sh preinstall.sh
RUN ./preinstall.sh

ENV CONNECT_PLUGIN_PATH /usr/share/java,/usr/share/confluent-hub-components,/usr/share/plugins

# Hack
COPY debezium/debezium_2.0.0.Beta2/debezium-connector-mongodb-2.0.0-SNAPSHOT.jar /usr/share/plugins/debezium-connector-mongodb/debezium-connector-mongodb-2.0.0.Beta1.jar

# preinstall.sh and the COPY above unpack into /usr/share/plugins as root. Hand
# the plugin tree to the user Connect actually runs as. The JVM truststore under
# /etc/pki stays root-owned: it is 0444 and only read at runtime.
RUN chown -R kafka:kafka /usr/share/plugins /tmp/cacerts

USER kafka
