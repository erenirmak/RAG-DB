# Start from pgvector image with PostgreSQL 16
FROM pgvector/pgvector:pg16

# Install required packages for building Apache AGE
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison \
    git \
    curl \
    ca-certificates \
    postgresql-server-dev-16 && \
    apt-get clean

# Set working directory
WORKDIR /tmp

# Clone and build Apache AGE from source
RUN git clone https://github.com/apache/age.git && \
    cd age && \
    make PG_CONFIG=/usr/lib/postgresql/16/bin/pg_config && \
    make install

# Create initialization script to load Apache AGE and create required DBs
RUN mkdir -p /docker-entrypoint-initdb.d

# This script runs at container initialization to:
# 1. Create "vector" and "graph" databases
# 2. Load the AGE extension in "graph"
RUN echo "\
#!/bin/bash\n\
psql -v ON_ERROR_STOP=1 --username \"\$POSTGRES_USER\" --dbname \"\$POSTGRES_DB\" <<-EOSQL\n\
    CREATE DATABASE vector;\n\
    CREATE DATABASE graph;\n\
EOSQL\n\
psql -v ON_ERROR_STOP=1 --username \"\$POSTGRES_USER\" --dbname \"graph\" <<-EOSQL\n\
    CREATE EXTENSION age;\n\
    LOAD 'age';\n\
    SET search_path TO ag_catalog, '\$user', public;\n\
EOSQL\n" > /docker-entrypoint-initdb.d/init-db.sh

# Ensure script is executable
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

# Expose PostgreSQL port
EXPOSE 5432
