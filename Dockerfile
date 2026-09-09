FROM ubuntu:24.04

LABEL maintainer "Arthur Precht <arthurfprecht@gmail.com>"

ARG XLNX_VIVADO_VERSION=2025.2
ARG XLNX_UNIFIED_INSTALLER=FPGAs_AdaptiveSoCs_Unified_SDI_2025.2_0530_0145_Lin64.bin
ARG XLNX_VIVADO_AUTH_FILE=wi_authentication_key
ARG XLNX_VIVADO_BATCH_CONFIG_FILE=install_config_vivado.txt
ARG XLNX_PETALINUX_BATCH_CONFIG_FILE=install_config_petalinux.txt

ENV XLNX_VIVADO_VERSION=${XLNX_VIVADO_VERSION}
ENV XLNX_INSTALL_LOCATION=/tools/Xilinx

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get upgrade -y

RUN apt-get install -y -qq apt-utils
RUN apt-get install -y -qq locales && \
	locale-gen en_US.UTF-8

# Install base requirements
RUN apt-get install -y -qq \
	sudo \
	gosu \
	nano \
	tmux \
	htop \
	wget

# Required libtinfo5 as AR 76616, found at https://adaptivesupport.amd.com/s/article/76616?language=en_US
RUN wget https://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.3_amd64.deb && \
	sudo apt install ./libtinfo5_6.3-2ubuntu0.3_amd64.deb -y

# Requirements for Vitis
# rlwrap to fix not opening XSDB server under Ubuntu 22.04 or newer verions to fix a bug in XSDB
RUN apt-get install -y -qq \
	default-jre \
	rlwrap

# Requirements for DocNav
# RUN apt-get install -y -qq \
#	libnss3

# Requirements for Vitis and Vivado
RUN apt-get install -y -qq \
	libgtk2.0-0 \
	libswt-gtk-4-java \
	xorg

# Requirements for PetaLinux (Listed here just as a reference, since PetaLinux is not installed)
RUN apt-get install -y -qq \
	iproute2 \
	gcc \
	g++ \
	net-tools \
	libncurses5-dev \
	zlib1g:i386 \
	libssl-dev \
	flex \
	bison \
	libselinux1 \
	xterm \
	autoconf \
	libtool \
	texinfo \
	zlib1g-dev \
	gcc-multilib \
	build-essential \
	screen \
	pax \
	gawk \
	python3 \
	python3-pexpect \
	python3-pip \
	python3-git \
	python3-jinja2 \
	xz-utils \
	debianutils \
	iputils-ping \
	libegl1-mesa-dev \
	libsdl1.2-dev \
	pylint \
	cpio \
	rsync \
	bc


RUN apt-get autoclean && \
	apt-get autoremove && \
	apt-get remove wget -y && \
	rm ./libtinfo5_6.3-2ubuntu0.3_amd64.deb

# Copy the vivado installation files
COPY ${XLNX_UNIFIED_INSTALLER} ${XLNX_INSTALL_LOCATION}/tmp/${XLNX_UNIFIED_INSTALLER}
COPY ${XLNX_VIVADO_BATCH_CONFIG_FILE} ${XLNX_INSTALL_LOCATION}/tmp/${XLNX_VIVADO_BATCH_CONFIG_FILE}
COPY ${XLNX_PETALINUX_BATCH_CONFIG_FILE} ${XLNX_INSTALL_LOCATION}/tmp/${XLNX_PETALINUX_BATCH_CONFIG_FILE}
COPY ${XLNX_VIVADO_AUTH_FILE} /root/.Xilinx/wi_authentication_key

# Prepare for Install
RUN cd ${XLNX_INSTALL_LOCATION}/tmp/ && \
	chmod +x ${XLNX_UNIFIED_INSTALLER}	

# Install Vivado
RUN cd ${XLNX_INSTALL_LOCATION}/tmp/ && \
	./${XLNX_UNIFIED_INSTALLER} -- \
	--agree XilinxEULA,3rdPartyEULA \
	--batch Install \
	--config ${XLNX_INSTALL_LOCATION}/tmp/${XLNX_VIVADO_BATCH_CONFIG_FILE}

# Install Petalinux
RUN cd ${XLNX_INSTALL_LOCATION}/tmp/ && \
	./${XLNX_UNIFIED_INSTALLER} -- \
	--agree XilinxEULA,3rdPartyEULA \
	--batch Install \
	--config ${XLNX_INSTALL_LOCATION}/tmp/${XLNX_PETALINUX_BATCH_CONFIG_FILE}	
	
# Cleanup Install
RUN rm -rf ${XLNX_INSTALL_LOCATION}/tmp && \
	rm -rf /root/.Xilinx/wi_authentication_key 
	
# Remove default ubuntu user that causes conflicts with the entrypoint
RUN deluser --remove-home ubuntu

#Fix not opening Vitis under Ubuntu 24.04 latest verions
RUN cd ${XLNX_INSTALL_LOCATION}/${XLNX_VIVADO_VERSION}/Vitis/lib/lnx64.o/Ubuntu && \
	mv libstdc++.so libstdc++.so.bkup && \
	mv libstdc++.so.6 libstdc++.so.6.bkup && \
	ln -s /lib/x86_64-linux-gnu/libstdc++.so.6 libstdc++.so.6 && \
	ln -s /lib/x86_64-linux-gnu/libstdc++.so.6 libstdc++.so
	
#Fix not opening XSDB server due to buggy rlwrap under Ubuntu 22.04 or newer verions
RUN cd ${XLNX_INSTALL_LOCATION}/${XLNX_VIVADO_VERSION}/Vitis/bin/unwrapped/lnx64.o && \
	mv rlwrap rlwrap.old && \
	ln -s /usr/bin/rlwrap rlwrap

# Set up the work environment
RUN mkdir ${HOME}/Projects
RUN mkdir ${HOME}/Workspaces

# Set up the entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash", "-c", "source ${XLNX_INSTALL_LOCATION}/${XLNX_VIVADO_VERSION}/Vivado/settings64.sh;source ${XLNX_INSTALL_LOCATION}/${XLNX_VIVADO_VERSION}/Vitis/settings64.sh;source ${XLNX_INSTALL_LOCATION}/${XLNX_VIVADO_VERSION}/PetaLinux/tool/settings.sh;export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${XLNX_INSTALL_LOCATION}/${XLNX_VIVADO_VERSION}/lib/lnx64.o/;/bin/bash"]
