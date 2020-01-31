# Base Image
FROM ubuntu:latest

# Metadata
MAINTAINER William Poehlman <william.poehlman@sagebase.org>
LABEL base_image="ubuntu:latest"
LABEL about.summary="Docker image for the STAR read aligner"
LABEL about.home="https://github.com/alexdobin/STAR"
LABEL about.license="SPDX:MIT"
LABEL about.tags="RNASeq"

# Install dependencies
RUN apt-get update \
 && apt-get install -y \
    binutils \
    build-essential \
    libz-dev \
    wget 

# Install STAR aligner
RUN wget https://github.com/alexdobin/STAR/archive/2.5.1b.tar.gz \
 && tar -xf 2.5.1b.tar.gz \
 && rm 2.5.1b.tar.gz \
 && cd STAR-2.5.1b \
 && make \
 && cp bin/Linux_x86_64/STAR /usr/bin \
 && cd .. \
 && rm -rf STAR-2.5.1b

CMD ["/bin/bash"]
