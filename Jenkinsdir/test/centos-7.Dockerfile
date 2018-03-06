# Pull base image from official repo
FROM centos:centos7.4.1708

# Install all current updates
RUN yum -q clean expire-cache \
	&& yum -y upgrade \
	&& yum -q clean packages

# Install common requirements
RUN yum -q clean expire-cache \
	&& yum -y install \
	git \
	wget \
	unzip \
	&& yum -q clean packages

# Install Python 3.5 from PIUS repo
RUN yum -q clean expire-cache \
	&& yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
	&& yum -y install \
	python35u \
	python35u-pip \
	python35u-setuptools \
	&& yum -q clean packages

# Install some Python dev tools
RUN yum -q clean expire-cache \
	&& yum -y install \
	python35u-devel \
	python35u-libs \
	python35u-tools \
	&& yum -q clean packages

# Install extra dev tools
RUN yum -q clean expire-cache \
	&& yum -y install \
	gcc \
	make \
	&& yum -q clean packages

# Install extra deps \
RUN yum -q clean expire-cache \
	&& yum -y install \
	which \
	openssl-devel \
	gmp-devel \
	flex \
	bison \
	libtool \
	automake \
	&& yum -q clean packages
#	python3-nacl \
#	libindy-crypto=0.2.0 \
#	libindy=1.3.1~403 \

# Get script directory from build argument
ARG dir=.

# Build and install PBC from source
COPY ${dir}/../build-pbc.sh build-pbc.sh
RUN ./build-pbc.sh install '0.5.14' 'https://github.com/digital-me/pbc.git'

# Copy and install requirements
COPY ${dir}/requirements.txt requirements.txt
RUN pip3.5 install --upgrade -r requirements.txt

# Add user to build and package
ARG uid=1000
ARG user=indy
ARG gid=1000
ARG group=indy

RUN groupadd -g "${gid}" "${group}" && useradd -ms /bin/bash -g "${group}" -u "${uid}" "${user}"
