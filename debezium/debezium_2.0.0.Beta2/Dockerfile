FROM debezium/connect:2.0.0.Beta1

USER root
RUN microdnf install -y perl openssl wget && microdnf clean all
COPY debezium/debezium_2.0.0.Beta2/preinstall.sh preinstall.sh
RUN ./preinstall.sh

ENV CONNECT_PLUGIN_PATH /usr/share/java,/usr/share/confluent-hub-components,/usr/share/plugins

# Hack
COPY debezium/debezium_2.0.0.Beta2/debezium-connector-mongodb-2.0.0-SNAPSHOT.jar /usr/share/plugins/debezium-connector-mongodb/debezium-connector-mongodb-2.0.0.Beta1.jar
