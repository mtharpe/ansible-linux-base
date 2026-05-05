FROM docker.io/library/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 python3-pip ansible openssh-server ca-certificates sudo \
    && rm -rf /var/lib/apt/lists/*
