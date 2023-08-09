FROM debian:bookworm

SHELL ["/bin/bash", "-c"]

ENV IDF_TOOLS_PATH /opt/esp

RUN mkdir -p $IDF_TOOLS_PATH

ENV IDF_PATH $IDF_TOOLS_PATH/idf
ENV ESP_IDF_VERSION ea5e0ff298e6257b31d8e0c81435e6d3937f04c7

ENV MATTER_PATH $IDF_TOOLS_PATH/matter
ENV ESP_MATTER_VERSION release/v1.1

# esp-idf
# https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html
RUN apt-get update && apt-get install -y --no-install-recommends \
        git wget flex bison gperf python3 python3-pip python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -f /usr/lib/python*/EXTERNALLY-MANAGED

RUN git clone --recursive --shallow-submodules --depth 1 https://github.com/espressif/esp-idf.git -b $ESP_IDF_VERSION $IDF_PATH || ( \
        git clone https://github.com/espressif/esp-idf.git $IDF_PATH &&\
        cd $IDF_PATH &&\
        git checkout $ESP_IDF_VERSION &&\
        git submodule update --init --depth 1 --recursive \
    ) &&\
    cd $IDF_PATH &&\
    ./install.sh esp32c6,esp32h2 &&\
    rm -rf .git

# esp-matter
# https://docs.espressif.com/projects/esp-matter/en/latest/esp32/developing.html
# https://github.com/espressif/connectedhomeip/blob/v1.1-branch/docs/guides/BUILDING.md#prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
        git gcc g++ pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -f /usr/lib/python*/EXTERNALLY-MANAGED

RUN git clone --depth 1 https://github.com/espressif/esp-matter.git -b $ESP_MATTER_VERSION $MATTER_PATH &&\
    cd $MATTER_PATH &&\
    git submodule update --init --depth 1 &&\
    cd connectedhomeip/connectedhomeip &&\
    ./scripts/checkout_submodules.py --platform esp32 linux --shallow &&\
    sed -i "s|gdbgui.*$||g" scripts/setup/requirements.esp32.txt &&\
    cd ../.. &&\
    . $IDF_PATH/export.sh &&\
    ./install.sh &&\
    rm -rf .git

COPY entrypoint.sh $IDF_TOOLS_PATH/entrypoint.sh
ENTRYPOINT ["$IDF_TOOLS_PATH/entrypoint.sh"]
