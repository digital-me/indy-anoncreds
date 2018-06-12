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

# Install extra deps \
RUN yum -q -y update \
	&& yum -y install \
	createrepo \
	sudo \
	&& yum -q clean all

# Add Indy repo
ARG repo_baseurl=http://orion.boxtel
ARG repo_path=rpm/sovrin
ARG repo_branch=master
RUN echo "[indy]" > /etc/yum.repos.d/indy.repo \
	&& echo "name=Hyperledger Indy Packages for Enterprise Linux 7 - $basearch" >> /etc/yum.repos.d/indy.repo \
	&& echo "baseurl=${repo_baseurl}/${repo_path}/centos-7/${repo_branch}/" >> /etc/yum.repos.d/indy.repo \
	&& echo "enabled=1" >> /etc/yum.repos.d/indy.repo \
	&& echo "skip_if_unavailable = 1" >> /etc/yum.repos.d/indy.repo \
	&& echo "gpgcheck=0" >> /etc/yum.repos.d/indy.repo

# Parameters for default user:group
ARG uid=1000
ARG user=indy
ARG gid=1000
ARG group=indy

# Add user to build
RUN groupadd -g "${gid}" "${group}" && useradd -ms /bin/bash -g "${group}" -u "${uid}" "${user}"

# Add user to sudoers
RUN echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Get script directory from lazyLib at last to avoid warning w/o invalidating the cache 
ARG dir=.
