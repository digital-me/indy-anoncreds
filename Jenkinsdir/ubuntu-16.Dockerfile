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
	python3-nacl \
	&& apt-get clean
#	libindy-crypto=0.2.0 \
#	libindy=1.3.1~403 \

# Copy and install requirements
ARG dir=.
COPY ${dir}/requirements.txt requirements.txt
RUN pip3 install --upgrade -r requirements.txt
