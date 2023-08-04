FROM debian:bookworm

ENV ESP_IDF_VERSION v4.4.3
ENV ESP_MATTER_VERSION release/v1.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake ninja python3 \
    &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN mkdir /esp

WORKDIR /esp

RUN git clone --recursive --depth 1 https://github.com/espressif/esp-idf.git -b $ESP_IDF_VERSION &&\
    cd esp-idf &&\
    ./install.sh

RUN git clone --depth 1 https://github.com/espressif/esp-matter.git -b $ESP_MATTER_VERSION &&\
    cd esp-matter &&\
    git submodule update --init --depth 1 &&\
    cd ./connectedhomeip/connectedhomeip &&\
    ./scripts/checkout_submodules.py --platform esp32 linux --shallow &&\
    cd ../.. &&\
    ./install.sh
