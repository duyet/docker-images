FROM debezium/connect:3.0.0.Final

USER root
RUN microdnf install -y perl openssl wget && microdnf clean all
COPY debezium/debezium_3.0.0.Final/preinstall.sh preinstall.sh
RUN ./preinstall.sh

ENV CONNECT_PLUGIN_PATH /usr/share/java,/usr/share/confluent-hub-components,/usr/share/plugins
