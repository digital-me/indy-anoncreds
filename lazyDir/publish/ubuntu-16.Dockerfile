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
	sudo \
	&& apt-get clean

# Install extra deps \
RUN apt-get -y update \
	&& apt-get -y install \
	dpkg-dev \
	software-properties-common \
	&& apt-get clean

# Add Indy repo
ARG repo_baseurl=http://orion.boxtel
ARG repo_path=deb
ARG repo_branch=master
#RUN apt-add-repository -y -u "deb ${repo_baseurl}/${repo_path} xenial ${repo_branch}"

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
