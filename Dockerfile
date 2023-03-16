FROM ubuntu:20.04

WORKDIR /work
COPY ./setup-system.sh .
RUN ./setup-system.sh --install