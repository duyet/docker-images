FROM postgres:latest
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

# Set default environment variables (can be overridden)
ENV POSTGRES_DB=postgres
ENV POSTGRES_USER=postgres
# ENV POSTGRES_PASSWORD=password

# Copy custom configuration or initialization scripts if needed
# COPY postgresql.conf /etc/postgresql/postgresql.conf
# COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/