FROM debezium/connect:1.9.5.Final

USER root
RUN microdnf install -y perl openssl && microdnf clean all
COPY debezium/debezium_1.9.5.Final/preinstall.sh preinstall.sh
RUN ./preinstall.sh

# USER kafka
