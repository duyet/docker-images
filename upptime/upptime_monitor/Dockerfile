FROM node:12

USER root
WORKDIR /app

RUN git clone --depth 1 --branch master https://github.com/upptime/uptime-monitor.git /upptime && \
    cd /upptime && \
    npm install

ENTRYPOINT ["node", "/upptime/dist/index.js"]
