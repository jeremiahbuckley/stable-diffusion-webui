FROM nvidia/cuda:11.3.1-runtime-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /sd

SHELL ["/bin/bash", "-c"]

#RUN apt-get update && \
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && \
    apt-get install -y libglib2.0-0 wget libsm6 libxext6 libxrender-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget -O ~/miniconda.sh -q --show-progress --progress=bar:force https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh
ENV PATH=$CONDA_DIR/bin:$PATH

# Install font for prompt matrix
COPY /data/DejaVuSans.ttf /usr/share/fonts/truetype/

EXPOSE 7860

COPY ./environment.yaml /sd/
COPY ./env1.yaml /sd/
COPY ./setup.py /sd/
RUN conda env update --file env1.yaml --prune \
&& conda clean --all
RUN conda env update --file environment.yaml --prune \
&& conda clean --all

COPY ./model-download.sh /sd/
RUN /sd/model-download.sh

ENV VALIDATE_MODELS=$false

COPY ./entrypoint.sh /sd/
COPY ./ /sd/

ENTRYPOINT /sd/entrypoint.sh
