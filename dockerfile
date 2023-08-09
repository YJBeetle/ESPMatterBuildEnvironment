FROM debian:bookworm

ENV ESP_IDF_VERSION v5.0.1
ENV ESP_MATTER_VERSION release/v1.1

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN mkdir /esp

WORKDIR /esp

SHELL ["/bin/bash", "-c"]

# esp-idf
RUN apt-get update && apt-get install -y --no-install-recommends \
        cmake \
        ninja-build \
        python3-venv \
        libusb-1.0-0 \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN git clone --recursive --shallow-submodules --depth 1 https://github.com/espressif/esp-idf.git -b $ESP_IDF_VERSION || ( \
        git clone https://github.com/espressif/esp-idf.git &&\
        cd esp-idf &&\
        git checkout $ESP_IDF_VERSION &&\
        git submodule update --init --depth 1 --recursive \
    ) &&\
    cd esp-idf &&\
    ./install.sh esp32,esp32c2,esp32c3,esp32s2,esp32s3 &&\
    rm -rf .git

# esp-matter
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-dev \
        python3-pip \
        libssl-dev \
        libgirepository1.0-dev \
        libcairo2-dev \
        libreadline-dev \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm /usr/lib/python*/EXTERNALLY-MANAGED

RUN git clone --depth 1 https://github.com/espressif/esp-matter.git -b $ESP_MATTER_VERSION &&\
    cd esp-matter &&\
    git submodule update --init --depth 1 &&\
    cd connectedhomeip/connectedhomeip &&\
    ./scripts/checkout_submodules.py --platform esp32 linux --shallow &&\
    sed -i "s|gdbgui.*$||g" scripts/setup/requirements.esp32.txt &&\
    cd ../.. &&\
    . /esp/esp-idf/export.sh &&\
    ./install.sh &&\
    rm -rf .git

WORKDIR /src
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
