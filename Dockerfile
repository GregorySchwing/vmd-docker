# syntax=docker/dockerfile:1
FROM ubuntu:22.04
# To get add-apt-repository command
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:josh-vermaas/vmd-things
RUN apt-get update && apt-get install -y surf=1.0-1 msms stride libactc actc-dev
RUN apt-mark hold surf
#Package building and general compilation 
RUN apt-get update && apt-get install -y devscripts\
					 debhelper 
#VMD required headers and libraries. 
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y libtachyon-mt-0-dev \
					 python3.10-dev \
					 tcl8.6-dev\
					 tk8.6-dev\
					 libnetcdf-dev\
					 libpng-dev\
					 python3-numpy\
					 python3-tk\
					 mesa-common-dev\
					 libglu1-mesa-dev\
					 libxinerama-dev\
					 libfltk1.3-dev\
					 coreutils\
					 sed
					 
RUN apt-get update && apt-get install -y wget
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
RUN dpkg -i cuda-keyring_1.0-1_all.deb
RUN apt-get update && apt-get install -y cuda

#Clone VMD


RUN mkdir vmdpackaging
RUN wget --directory-prefix=/vmdpackaging https://www.ks.uiuc.edu/Research/vmd/vmd-1.9.4/files/alpha/vmd-1.9.4a57.src.tar.gz
RUN mv /vmdpackaging/vmd-1.9.4a57.src.tar.gz /vmdpackaging/vmd_1.9.4a57.orig.tar.gz
RUN mkdir /vmdpackaging/vmd-1.9.4a57
RUN apt-get update && apt-get install -y git

RUN tar -zxf /vmdpackaging/vmd_1.9.4a57.orig.tar.gz --directory /vmdpackaging/vmd-1.9.4a57
RUN mv /vmdpackaging/vmd-1.9.4a57/vmd-1.9.4a57 /vmdpackaging/vmd-1.9.4a57/vmd
#Get the initial, not totally broken debian files.

RUN git --git-dir /vmdpackaging/vmd-1.9.4a57 init
RUN git --git-dir /vmdpackaging/vmd-1.9.4a57 remote add origin https://github.com/GregorySchwing/vmd-packaging-instructions.git
RUN git --git-dir /vmdpackaging/vmd-1.9.4a57 fetch origin
RUN git --git-dir /vmdpackaging/vmd-1.9.4a57 --work-tree /vmdpackaging/vmd-1.9.4a57 checkout -b main --track origin/main
RUN git --git-dir /vmdpackaging/vmd-1.9.4a57 --work-tree /vmdpackaging/vmd-1.9.4a57 checkout 8e1fb095f1570824ac623695f6b76d623e0437c1

RUN sed -i 's/tcl8.5/tcl8.6/g' /vmdpackaging/vmd-1.9.4a57/plugins/Make-arch
RUN cp /vmdpackaging/vmd-1.9.4a57/edited/configure /vmdpackaging/vmd-1.9.4a57/vmd/configure
RUN cp /vmdpackaging/vmd-1.9.4a57/edited/vmd.sh /vmdpackaging/vmd-1.9.4a57/vmd/bin/vmd.sh

# Clone my copy of vmd
RUN git clone https://github.com/GregorySchwing/vmd.git
#RUN mv vmd/plugins /vmdpackaging/vmd-1.9.4a57/plugins
RUN mv vmd/vmd-1.9.4a57/src /vmdpackaging/vmd-1.9.4a57/vmd/src

RUN cd /vmdpackaging/vmd-1.9.4a57; debuild -b
RUN cd /vmdpackaging; sudo dpkg -i vmd_1.9.4a55-3_amd64.deb vmd-plugins_1.9.4a55-3_amd64.deb
#RUN cd /vmdpackaging; sudo dpkg -i vmd-cuda_1.9.4a55-3_amd64.deb vmd-plugins_1.9.4a55-3_amd64.deb
#RUN cd /vmdpackaging; sudo dpkg -i vmd-cuda_1.9.4a57-1_amd64.deb vmd-plugins_1.9.4a57-1_amd64.deb
