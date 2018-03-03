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

# Install extra deps \
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

# Build and install PBC from source, using a git commit because no tag
COPY ${dir}/install_pbc.sh install_pbc.sh
RUN ./install_pbc.sh 656ae0c90e120eacd3dc0d76dbc9504f8aca4ba8

# Copy and install requirements
COPY ${dir}/requirements.txt requirements.txt
RUN pip3 install --upgrade -r requirements.txt
