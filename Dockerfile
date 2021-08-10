FROM nvidia/cuda:11.0-base-ubuntu20.04

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    tmux \
    wget \
    vim \
    && rm -rf /var/lib/apt/lists/*

# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Asia/Singapore /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# Expose ports
EXPOSE 6006
EXPOSE 6379

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user 
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user
WORKDIR /home/user
# Install zsh related
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
    -t ys \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting
RUN sudo chsh -s /bin/zsh

# Install Miniconda and Python 3.8
ENV PATH=/home/user/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false
RUN curl -sLo ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p ~/miniconda \
    && rm ~/miniconda.sh \
    && conda install -y python==3.8.3 \
    && conda clean -ya



# CUDA 11.0-specific steps
RUN conda install -y -c pytorch \
    cudatoolkit=11.0.221 \
    "pytorch=1.7.0=py3.8_cuda11.0.221_cudnn8.0.3_0" \
    "torchvision=0.8.1=py38_cu110" \
    && conda clean -ya

# conda install dependencies
RUN conda install -y numpy \
    && conda install -y -c anaconda pillow \
    && conda install -y -c anaconda pylint \
    && conda install -y -c conda-forge autopep8 \
    && conda install -y ipykernel \
    && conda install -y h5py \
    && conda install -c conda-forge faiss-gpu \
    && conda install -c conda-forge scikit-learn \
    && conda install -c conda-forge natsort \
    && conda install -c conda-forge tqdm \
    && conda install -c conda-forge opencv \
    && conda clean -ya

# pip install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir tensorboardX redis matplotlib pandas torchmetrics tensorboard

# set tmux
RUN sudo echo "set-option -g default-shell /bin/zsh" >> ~/.tmux.conf

# Set the default command to zsh
ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]