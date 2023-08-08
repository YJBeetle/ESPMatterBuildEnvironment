FROM debian:bookworm

ENV ESP_IDF_VERSION v5.0.1
ENV ESP_MATTER_VERSION release/v1.1

# Clone
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN mkdir /esp

WORKDIR /esp

RUN git clone --recursive --shallow-submodules --depth 1 https://github.com/espressif/esp-idf.git -b $ESP_IDF_VERSION

RUN git clone --depth 1 https://github.com/espressif/esp-matter.git -b $ESP_MATTER_VERSION &&\
    cd esp-matter &&\
    git submodule update --init --depth 1

# Install

RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        ninja-build \
        puthon3-dev \
        python3-venv \
        python3-pip \
        libusb-1.0-0 \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN cd esp-idf &&\
    ./install.sh

RUN cd esp-matter/connectedhomeip/connectedhomeip &&\
    ./scripts/checkout_submodules.py --platform esp32 linux --shallow

RUN cd esp-matter &&\
    sed -i "s|gdbgui.*$||g" connectedhomeip/connectedhomeip/scripts/setup/requirements.esp32.txt &&\
    apt-get update && apt-get install -y --no-install-recommends libssl-dev libgirepository1.0-dev libcairo2-dev libreadline-dev && apt-get clean && rm -rf /var/lib/apt/lists/* &&\
    rm /usr/lib/python*/EXTERNALLY-MANAGED &&\
    ./install.sh
