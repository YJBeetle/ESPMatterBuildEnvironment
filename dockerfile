FROM espressif/idf:release-v5.1

ENV MATTER_PATH /opt/esp/matter
ENV ESP_MATTER_VERSION 1.1

# https://github.com/espressif/connectedhomeip/blob/v1.1-branch/docs/guides/BUILDING.md#prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
        git gcc g++ pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -f /usr/lib/python*/EXTERNALLY-MANAGED

# https://docs.espressif.com/projects/esp-matter/en/latest/esp32/developing.html
RUN git clone --depth 1 https://github.com/espressif/esp-matter.git -b release/v$ESP_MATTER_VERSION $MATTER_PATH &&\
    cd $MATTER_PATH &&\
    git submodule update --init --depth 1 &&\
    cd connectedhomeip/connectedhomeip &&\
    ./scripts/checkout_submodules.py --platform esp32 linux --shallow &&\
    sed -i "s|gdbgui.*$||g" scripts/setup/requirements.esp32.txt &&\
    cd ../.. &&\
    ./install.sh

COPY entrypoint.sh /opt/esp/entrypoint.sh
ENTRYPOINT ["/opt/esp/entrypoint.sh"]
