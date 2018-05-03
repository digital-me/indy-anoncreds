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

# Parameters for default user:group
ARG uid=1000
ARG user=indy
ARG gid=1000
ARG group=indy

# Add user to build
RUN groupadd -g "${gid}" "${group}" && useradd -ms /bin/bash -g "${group}" -u "${uid}" "${user}"

# Get script directory from lazyLib
ARG dir=.

# Build and install PBC from source
COPY ${dir}/../build-pbc.sh build-pbc.sh
RUN ./build-pbc.sh install

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

# Copy and install requirements
COPY ${dir}/requirements.txt requirements.txt
RUN pip3 install --upgrade -r requirements.txt
