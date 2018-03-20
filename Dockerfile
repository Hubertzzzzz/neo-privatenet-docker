# NEO private network - Dockerfile
FROM ubuntu:17.10

ENV DEBIAN_FRONTEND noninteractive

# Disable dotnet usage information collection
# https://docs.microsoft.com/en-us/dotnet/core/tools/telemetry#behavior
ENV DOTNET_CLI_TELEMETRY_OPTOUT 1

# Install system dependencies. always should be done in one line
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run
RUN apt-get update && apt-get install -y \
    libleveldb-dev \
    sqlite3 \
    libsqlite3-dev \
    libunwind8-dev \
    libssl-dev \
    git-core \
    wget \
    curl \
    unzip \
    screen \
    expect \
    vim \
    man

# Setup microsoft repositories
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-artful-prod artful main" > /etc/apt/sources.list.d/dotnetdev.list' \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
    && apt-get update && apt-get install -y dotnet-sdk-2.1.4

# APT cleanup to reduce image size
RUN rm -rf /var/lib/apt/lists/*

# Get the neo-cli package
RUN cd /home/ \
    && git clone https://github.com/neo-project/neo-cli.git \
    && cd neo-cli/neo-cli \
    && dotnet restore \
    && dotnet publish -c Release \
    && cp -r /home/neo-cli/neo-cli/bin/Release/netcoreapp2.0/publish/ /home/cli/

# Prepare consensus nodes
RUN cd /home/ \
    && git clone https://github.com/Hubert-Z/neo-cli-privatenet-docker.git \
    && cp -r /home/neo-cli-privatenet-docker/json/ /home/cli/json/ \
    && rm -rf /home/neo-cli-privatenet-docker/ \
    && cd /home/cli/ \
    && rm -f config.json protocol.json ChainPrivate/* \
    && cp /home/cli/json/config.json config.json \
    && cp /home/cli/json/protocol.json protocol.json