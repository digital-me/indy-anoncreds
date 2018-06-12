# Pull base image from official repo
FROM centos:centos7.5.1804

# Enable epel repo and Install all current updates
RUN yum -q -y update \
	&& rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
	&& yum -y install epel-release \
	&& rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 \
	&& yum -y upgrade \
	&& yum -q clean all

# Install common requirements
RUN yum -q -y update \
	&& yum -y install \
	git \
	wget \
	unzip \
	which \
	&& yum -q clean all

# Install Python 3.5 from PIUS repo
RUN yum -q -y update \
	&& yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
	&& rpm --import /etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY \
	&& yum -y install \
	python35u \
	python35u-pip \
	python35u-setuptools \
	&& yum -q clean all

# Install some Python dev tools
RUN yum -q -y update \
	&& yum -y install \
	python35u-devel \
	python35u-libs \
	python35u-tools \
	&& yum -q clean all

# Install extra dev tools
RUN yum -q -y update \
	&& yum -y install \
	gcc \
	make \
	&& yum -q clean all

# Install extra deps to build PBC
RUN yum -q -y update \
	&& yum -y install \
	openssl-devel \
	gmp-devel \
	flex \
	bison \
	libtool \
	automake \
	file \
	&& yum -q clean all
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

# Copy and install requirements
COPY ${dir}/requirements.txt requirements.txt
RUN pip3.5 install --upgrade -r requirements.txt
