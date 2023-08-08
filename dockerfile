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
        python3-full \
        &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

RUN cd esp-idf &&\
    ./install.sh

RUN cd esp-matter/connectedhomeip/connectedhomeip &&\
    ./scripts/checkout_submodules.py --platform esp32 linux --shallow

RUN cd esp-matter &&\
    rm /usr/lib/python*/EXTERNALLY-MANAGED &&\
    python3 -m pip install --upgrade setuptools &&\
    python3 -m pip install --upgrade pip &&\
    ./install.sh || echo "=RBQ=RBQ=RBQ=RBQ=RBQ=RBQ=RBQ=RBQ=RBQ=RBQ=RBQ=" && cat /esp/esp-matter/connectedhomeip/connectedhomeip/.environment/pigweed-venv/pip-requirements.log
