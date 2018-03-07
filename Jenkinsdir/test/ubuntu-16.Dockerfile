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

# Get script directory from build argument
ARG dir=.

# Build and install PBC from source
COPY ${dir}/../build-pbc.sh build-pbc.sh
RUN ./build-pbc.sh install

# Copy and install requirements
COPY ${dir}/requirements.txt requirements.txt
RUN pip3 install --upgrade -r requirements.txt

# Add user to build and package
ARG uid=1000
ARG user=indy
ARG gid=1000
ARG group=indy

RUN groupadd -g "${gid}" "${group}" && useradd -ms /bin/bash -g "${group}" -u "${uid}" "${user}"
