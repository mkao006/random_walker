############################################################
# Dockerfile to run a Django-based web application
# Based on an Ubuntu Image
############################################################

# Set the base image to use to Ubuntu
# FROM ubuntu:14.04
FROM jupyter/scipy-notebook

# Set the file maintainer
MAINTAINER Michal Kao

# Set env variables used in this Dockerfile (add a unique prefix, such as DOCKYARD)
# Local directory with project source
ENV DOCKYARD_SRC=/
# Directory in container for all project files
ENV DOCKYARD_SRVHOME=/srv
# Directory in container for project source files
ENV DOCKYARD_SRVPROJ=/srv/random_walker

USER root

# Update the default application repository sources list
RUN apt-get update && \
    apt-get -y upgrade
RUN apt-get update && \
    apt-get install -y \
    python \
    python-dev \
    python-pip \
    python-setuptools \
    software-properties-common \
    python-software-properties \
    wget

## Install postgres
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > \
    /etc/apt/sources.list.d/pgdg.list

RUN sudo apt-get install wget ca-certificates
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN sudo apt-get update && \
    apt-get upgrade &&\
    apt-get -y -q install\
    postgresql-9.3 \
    pgadmin3 \
    postgresql-client-9.3 \
    postgresql-contrib-9.3\
    postgresql-server-dev-9.3\
    libpq-dev \
    python-psycopg2


## These are required for postgis
RUN sudo apt-get update && \
    apt-get -y -q install \
    build-essential \
    libxml2-dev \
    libproj-dev \
    libjson0-dev \
    xsltproc \
    docbook-xsl \
    docbook-mathml \
    libgdal1-dev

## The following is necessary for Pillow
RUN apt-get install -y \
    libtiff5-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libfreetype6-dev \
    liblcms2-dev \
    libwebp-dev \
    tcl8.5-dev \
    tk8.5-dev \
    python-tk

# Install uwsgi
RUN apt-get install -y uwsgi

# Required for uwsgi
RUN apt-get install -y uwsgi-plugin-python

# Install Python dependencies
ADD requirements.txt $DOCKYARD_SRC
RUN pip install -r requirements.txt

# Create application subdirectories
WORKDIR $DOCKYARD_SRVHOME
RUN mkdir media static logs
VOLUME ["$DOCKYARD_SRVHOME/media/", "$DOCKYARD_SRVHOME/logs/"]

# Copy application source code to SRCDIR
COPY $DOCKYARD_SRC $DOCKYARD_SRVPROJ

# Port to expose
EXPOSE 8000

# Copy entrypoint script into the image
WORKDIR $DOCKYARD_SRVPROJ
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]