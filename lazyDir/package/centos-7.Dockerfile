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
	which \
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

# Install extra deps to build PBC
RUN yum -q clean expire-cache \
	&& yum -y install \
	which \
	openssl-devel \
	gmp-devel \
	flex \
	bison \
	libtool \
	automake \
	file \
	&& yum -q clean packages
#	python3-nacl \
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
RUN yum -q clean expire-cache \
	&& yum -y install \
	rpm-build \
	&& yum -q clean packages

# Install extra deps to install Ruby gems
RUN yum -q clean expire-cache \
	&& yum -y install \
	ruby \
	ruby-devel \
	rubygems \
	&& yum -q clean packages

# Install FPM gem to package Python modules
RUN gem install --no-ri --no-rdoc fpm

# Copy and install requirements
COPY ${dir}/requirements.txt requirements.txt
RUN pip3.5 install --upgrade -r requirements.txt
