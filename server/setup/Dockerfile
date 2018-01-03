FROM ubuntu:16.04

MAINTAINER "Ralph Wiedemeier" <ralph@framefactory.ch>
LABEL description="LAMP Stack for Smithsonian X 3D Legacy Website"
LABEL version="0.1"

# Install provisioning scripts
COPY *.sh /var/provisioning/
COPY *.env /var/provisioning/
WORKDIR /var/provisioning

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y apt-utils \
 && apt-get install -y dos2unix \
 && dos2unix *

# Run provisioning scripts
RUN bash -C './install.sh'

# Cleanup
RUN apt-get -y autoremove \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Entrypoint
CMD bash -C '/var/provisioning/run.sh'