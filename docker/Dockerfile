FROM ubuntu:24.04

USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    libopencv-dev \
    git \
    && \
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

USER ubuntu

RUN curl -fsSL https://install.julialang.org | sh -s -- --yes --default-channel=nightly
ENV PATH=/home/ubuntu/.juliaup/bin:$PATH
RUN julia --version

WORKDIR /home/ubuntu

RUN git clone https://github.com/AtelierArith/DocstringTranslationExoBackend.jl.git
RUN cd DocstringTranslationExoBackend.jl && \
    julia --project -e 'using Pkg; Pkg.instantiate()' && \
    julia --project -e 'using PythonCall'

EXPOSE 52415
ENTRYPOINT ["julia", "/home/ubuntu/DocstringTranslationExoBackend.jl/serveexo.jl"]
