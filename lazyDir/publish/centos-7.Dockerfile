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
	sudo \
	which \
	&& yum -q clean packages

# Add PIUS repo
RUN yum -q clean expire-cache \
	&& yum -y install https://centos7.iuscommunity.org/ius-release.rpm \
	&& rpm --import /etc/pki/rpm-gpg/IUS-COMMUNITY-GPG-KEY

# Install extra deps \
RUN yum -q clean expire-cache \
	&& yum -y install \
	createrepo \
	&& yum -q clean packages

# Add Indy repo
ARG repo_baseurl=http://orion.boxtel
ARG repo_path=rpm/sovrin
ARG repo_branch=master
RUN echo "[indy]" > /etc/yum.repos.d/indy.repo \
	&& echo "name=Hyperledger Indy Packages for Enterprise Linux 7 - $basearch" >> /etc/yum.repos.d/indy.repo \
	&& echo "baseurl=${repo_baseurl}/${repo_path}/${repo_branch}/" >> /etc/yum.repos.d/indy.repo \
	&& echo "enabled=1" >> /etc/yum.repos.d/indy.repo \
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
