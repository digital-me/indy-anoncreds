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

# Build and install PBC from source, using a git commit because no tag
COPY ${dir}/install_pbc.sh install_pbc.sh
RUN ./install_pbc.sh 656ae0c90e120eacd3dc0d76dbc9504f8aca4ba8

# Copy and install requirements
COPY ${dir}/requirements.txt requirements.txt
RUN pip3.5 install --upgrade -r requirements.txt
