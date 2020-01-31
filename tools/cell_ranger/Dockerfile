# Base Image
FROM ubuntu:bionic

# Metadata
LABEL base_image="ubuntu:bionic"
LABEL software="Cell Ranger"
LABEL software.version="3.0.2"
LABEL about.documentation="https://github.com/10XGenomics/cellranger"
LABEL about.summary="Docker image for the CellRanger software.  This image is not provided\
    or supported by 10X Genomics, and uses the unsupported source code on github"
LABEL about.license="SPDX:MIT"
LABEL about.tags="scRNA"

# install dependencies
RUN apt-get update \
 && apt-get install -y \
    binutils=2.30-21ubuntu1~18.04.2 \
    clang-6.0 \
    curl=7.58.0-2ubuntu3.8 \
    dpkg-dev=1.19.0.5ubuntu2.3 \
    g++=4:7.4.0-1ubuntu2.3 \
    gcc=4:7.4.0-1ubuntu2.3 \
    git=1:2.17.1-1ubuntu0.5 \
    golang-1.9 \
    libatlas-base-dev=3.10.3-5 \
    libbz2-dev=1.0.6-8.1ubuntu0.2 \
    libc6-dev=2.27-3ubuntu1 \
    liblz4-tool=0.0~r131-2ubuntu3 \
    liblzma-dev=5.2.2-1.3 \
    libopenblas-dev=0.2.20+ds-4 \
    make=4.1-9.1ubuntu1 \
    python-numpy=1:1.13.3-2ubuntu1 \
    python-pip=9.0.1-2.3~ubuntu1.18.04.1 \
    samtools=1.7-1 \
    wget=1.19.4-1ubuntu2.2 \
    zlib1g-dev=1:1.2.11.dfsg-0ubuntu2

# install python dependencies with pip
RUN pip install \
    cffi==1.13.2 \
    Cython==0.28.5 \
    docopts==0.6.1 \
    h5py==2.10.0 \
    Jinja2==2.10.3 \
    lz4==2.2.1 \
    pandas==0.24.2 \
    pyfasta==0.5.2 \
    pysam==0.15.3 \
    python-config==0.1.2 \
    pyvcf==0.6.8 \
    scipy==1.2.2 \
    sklearn==0.0 \
    tables==3.5.2

# export path to golang
ENV PATH="/usr/lib/go-1.9/bin:$PATH"

# download and install rustup
RUN curl https://sh.rustup.rs -sSf \
    | sh -s -- -y --profile minimal \
    --default-toolchain nightly

# export cargo path    
ENV PATH="/root/.cargo/bin:$PATH"

# install correct version of rustup
RUN rustup install 1.28.0 && rustup default 1.28.0

# Download precompiled martian and unpack
RUN wget https://github.com/martian-lang/martian/releases/download/v3.2.0/martian-v3.2.0-linux-x86_64.tar.gz \
  && tar -xf martian-v3.2.0-linux-x86_64.tar.gz && rm martian-v3.2.0-linux-x86_64.tar.gz

# Install STAR aligner
RUN wget https://github.com/alexdobin/STAR/archive/2.5.1b.tar.gz \
 && tar -xf 2.5.1b.tar.gz \
 && rm 2.5.1b.tar.gz \
 && make -C STAR-2.5.1b \
 && cp STAR-2.5.1b/bin/Linux_x86_64/STAR /usr/bin \
 && rm -rf STAR-2.5.1b

# Install tsne
RUN git clone https://github.com/wpoehlm/tsne.git \
 && cd tsne \
 && git checkout 075de5f641f7e222e40b8c4d407f95192e179228 \
 && make install \
 && cd .. \
 && rm -rf tsne

# clone cellranger sourcecode repo, cd into this dir, and install cellranger
RUN git clone https://github.com/wpoehlm/cellranger.git \ 
 && cd cellranger \
 && git checkout 5f5a6293bbc067e1965e50f0277286914b96c908 \
 && make 

# setup environment to run cellranger
ENV PATH /cellranger/bin/:/cellranger/lib/bin:/cellranger/tenkit/bin/:/cellranger/tenkit/lib/bin:/martian-v3.2.0-linux-x86_64/bin:$PATH

ENV PYTHONPATH /cellranger/lib/python:/cellranger/tenkit/lib/python:$PYTHONPATH

ENV MROPATH /cellranger/mro:$MROPATH
