FROM jenkins/jenkins:lts
MAINTAINER Santosh Rai <santosh.rai.acquis@gmail.com>

# Suppress apt installation warnings
ENV DEBIAN_FRONTEND=noninteractive

# Change to root user
USER root

# Used to set the docker group ID
# Set to 497 by default, which is the group ID used by AWS Linux ECS Instance
ARG DOCKER_GID=497

# Create Docker Group with GID
# Set default value of 497 if DOCKER_GID set to blank string by Docker Compose
RUN groupadd -g ${DOCKER_GID:-497} docker

# Used to control Docker and Docker Compose versions installed
# NOTE: As of February 2016, AWS Linux ECS only supports Docker 1.9.1
ARG DOCKER_ENGINE=17.12.1
ARG DOCKER_COMPOSE=1.24.0

# Install base packages
RUN apt-get update -y && \
    apt-get install apt-transport-https curl python-dev python-setuptools gcc make libssl-dev -y && \
    easy_install pip

# Install Docker Engine
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
#     echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list && \
#     apt-get update -y && \
#     apt-get purge lxc-docker* -y && \
#     apt-get install docker-ce=${DOCKER_ENGINE:-18.06.2}-0~trusty -y && \
#     usermod -aG docker jenkins && \
#     usermod -aG users jenkins

RUN apt-get update -qq \
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg2 software-properties-common 
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
RUN apt-get update  -qq \
    && apt-get install docker-ce=17.12.1~ce-0~debian -y
RUN sudo usermod -aG docker jenkins
RUN sudo usermod -aG users jenkins

# Install Docker Compose
RUN pip install docker-compose==${DOCKER_COMPOSE:-1.24.0} && \
    pip install ansible boto boto3

# Change to jenkins user
#USER jenkins

# Add Jenkins plugins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt