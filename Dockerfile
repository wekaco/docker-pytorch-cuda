ARG BUILD_CUDA_VERSION=11.0
ARG BUILD_CUDNN_VERSION=8

FROM nvidia/cuda:$BUILD_CUDA_VERSION-cudnn$BUILD_CUDNN_VERSION-runtime-ubuntu16.04

ARG BUILD_CUDA_VERSION
ARG BUILD_PYTORCH_VERSION=1.7.0
ARG BUILD_TORCHAUDIO_VERSION=0.7.0

# Export CUDA env variables
# ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda-10.2/lib64"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda-$CUDA_VERSION/lib64"
ENV CUDA_HOME="/usr/local/cuda"
# ENV PATH="/usr/local/cuda/bin:/usr/local/cuda-10.2/bin:$PATH"

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    sox \
    ffmpeg \
 && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Install Miniconda
RUN curl -L -so ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-4.7.12-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false

# Create a Python 3.6 environment
RUN /home/user/miniconda/bin/conda update -n base -c defaults conda \
 && /home/user/miniconda/bin/conda install conda-build \
 && /home/user/miniconda/bin/conda create -y --name py36 python=3.6.5 \
 && /home/user/miniconda/bin/conda clean -ya
ENV CONDA_DEFAULT_ENV=py36
ENV CONDA_PREFIX=/home/user/miniconda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH

RUN conda install pytorch==$BUILD_PYTORCH_VERSION cudatoolkit=$BUILD_CUDA_VERSION torchaudio==$BUILD_TORCHAUDIO_VERSION -c pytorch \
  && conda clean -ya
