FROM debian:bookworm

ENV ESP_IDF_VERSION v5.0.1
ENV ESP_MATTER_VERSION release/v1.1

# Clone
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        python3 \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN mkdir /esp

WORKDIR /esp

RUN git clone --recursive --shallow-submodules --depth 1 https://github.com/espressif/esp-idf.git -b $ESP_IDF_VERSION &&\
    rm -rf /esp/esp-idf/.git

RUN git clone --depth 1 https://github.com/espressif/esp-matter.git -b $ESP_MATTER_VERSION &&\
    cd esp-matter &&\
    git submodule update --init --depth 1 &&\
    cd connectedhomeip/connectedhomeip &&\
    ./scripts/checkout_submodules.py --platform esp32 linux --shallow

# Install

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        ninja-build \
        python3-venv \
        libusb-1.0-0 \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN cd esp-idf &&\
    ./install.sh esp32s3

RUN cd esp-matter &&\
    sed -i "s|gdbgui.*$||g" connectedhomeip/connectedhomeip/scripts/setup/requirements.esp32.txt &&\
    apt-get update && apt-get install -y --no-install-recommends \
        python3-dev \
        python3-pip \
        libssl-dev \
        libgirepository1.0-dev \
        libcairo2-dev \
        libreadline-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/* &&\
    rm /usr/lib/python*/EXTERNALLY-MANAGED &&\
    ./install.sh
