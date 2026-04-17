FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV FSLDIR=/opt/fsl

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl bzip2 \
	&& rm -rf /var/lib/apt/lists/* \
	&& curl -fsSL https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/getfsl.sh | bash -s -- "$FSLDIR" \
	&& printf '%s\n' 'export FSLDIR=/opt/fsl' '. "$FSLDIR/etc/fslconf/fsl.sh"' > /etc/profile.d/fsl.sh

RUN apt-get update && apt-get install -y --no-install-recommends \
	bc \
	binutils \
	libglib2.0-0 \
	libgomp1 \
	libgl1 \
	libglu1-mesa \
	libxmu6 \
	perl \
	psmisc \
	sudo \
	tar \
	tcsh \
	unzip \
	uuid-dev \
	vim-common \
	libjpeg62-dev \
	ca-certificates \
	curl \
	&& rm -rf /var/lib/apt/lists/*

ENV FREESURFER_HOME=/usr/local/freesurfer

RUN curl -fL https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.1/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.1.tar.gz -o /tmp/freesurfer.tar.gz \
	&& tar -C /usr/local -xzvf /tmp/freesurfer.tar.gz \
	&& rm -f /tmp/freesurfer.tar.gz \
	&& printf '%s\n' 'export FREESURFER_HOME=/usr/local/freesurfer' '. "$FREESURFER_HOME/SetUpFreeSurfer.sh"' > /etc/profile.d/freesurfer.sh

COPY ./freesurfer_license.txt /usr/local/freesurfer/license.txt

RUN curl -fL https://www.humanconnectome.org/storage/app/media/workbench/workbench-linux64-v2.1.0.zip -o /tmp/workbench.zip \
	&& unzip -q /tmp/workbench.zip -d /opt \
	&& rm -f /tmp/workbench.zip

ENV CARET7DIR=/opt/workbench/bin_linux64
ENV PATH=${CARET7DIR}:${PATH}

RUN apt-get update && apt-get install -y --no-install-recommends \
	libopenblas0 \
	&& rm -rf /var/lib/apt/lists/* \
	&& curl -fL https://github.com/ecr05/MSM_HOCR/releases/download/v3.0FSL/msm_ubuntu_v3 -o /usr/local/bin/msm_ubuntu_v3 \
	&& chmod +x /usr/local/bin/msm_ubuntu_v3


RUN apt-get update && apt-get install -y --no-install-recommends \
	python3 \
	python3-pip \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -fL https://github.com/Washington-University/gradunwarp/archive/refs/tags/1.2.3.tar.gz -o /tmp/gradunwarp.tar.gz \
	&& tar -C /tmp -xzvf /tmp/gradunwarp.tar.gz \
	&& rm -f /tmp/gradunwarp.tar.gz \
	&& cd /tmp/gradunwarp-1.2.3 \
	&& pip3 install --no-cache-dir -r requirements.txt \
	&& pip3 install .


RUN pip3 install --no-cache-dir nibabel numpy 

#RUN useradd --create-home --shell /bin/bash hcp
#USER hcp
