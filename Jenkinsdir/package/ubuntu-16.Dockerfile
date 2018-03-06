# Pull base image from official repo
FROM ubuntu:16.04

# Install all current updates
RUN apt-get -y update \
	&& apt-get -y dist-upgrade \
	&& apt-get clean

# Install common requirements
RUN apt-get -y update \
	&& apt-get -y install \
	git \
	wget \
	unzip \
	&& apt-get clean

# Install Python 3.5
RUN apt-get -y update \
	&& apt-get -y install \
	python3.5 \
	python3-pip \
	python3-setuptools \
	&& apt-get clean

# Install some Python dev tools
#RUN apt-get -y update \
#	&& apt-get -y install \
#	python3-dev \
#	python3-libs \
#	python3-tools \
#	&& apt-get clean

# Install extra dev tools
RUN apt-get -y update \
	&& apt-get -y install \
	gcc \
	make \
	&& apt-get clean

# Install extra deps to build PBC
RUN apt-get -y update \
	&& apt-get -y install \
	libssl-dev \
	libgmp-dev \
	flex \
	bison \
	libtool \
	automake \
	&& apt-get clean
#	libindy-crypto=0.2.0 \
#	libindy=1.3.1~403 \

# Install extra deps to package PBC
RUN apt-get -y update \
	&& apt-get -y install \
	debhelper \
	autotools-dev \
	libreadline-dev \
	&& apt-get clean

# Install extra deps to install Ruby gems
RUN apt-get -y update \
	&& apt-get -y install \
	ruby \
	ruby-dev \
	rubygems \
	&& apt-get clean

# Install FPM gem to package Python modules
RUN gem install --no-ri --no-rdoc fpm

# Get script directory from build argument
ARG dir=.

# Build and install PBC from source
COPY ${dir}/../build-pbc.sh build-pbc.sh
RUN ./build-pbc.sh install '0.5.14' 'https://github.com/digital-me/pbc.git'

# Copy and install requirements
COPY ${dir}/requirements.txt requirements.txt
RUN pip3 install --upgrade -r requirements.txt

# Add user to build and package
ARG uid=1000
ARG user=indy
RUN useradd -ms /bin/bash -u "${uid}" "${user}"
