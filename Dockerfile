# Use Ubuntu 24.04 (noble) as the base image
FROM ubuntu:24.04

# Set environment variables to reduce interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Set the Ring release version
ENV RING_VERSION=1.22

# Install necessary packages
RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential \
    wget \
    unzip \
    cmake \
    meson \
    ninja-build \
    ca-certificates \
    git \
    unixodbc \
    unixodbc-dev \
    libmariadb-dev-compat \
    libpq-dev \
    libcurl4-gnutls-dev \
    libssl-dev \
    liballegro5-dev \
    liballegro-image5-dev \
    liballegro-ttf5-dev \
    liballegro-audio5-dev \
    liballegro-acodec5-dev \
    liballegro-dialog5-dev \
    liballegro-physfs5-dev \
    qtbase5-dev \
    qtchooser \
    qt5-qmake \
    qtbase5-dev-tools \
    qtmultimedia5-dev \
    libqt5multimedia5-plugins \
    libqt5webkit5-dev \
    libqt5serialport5-dev \
    qtconnectivity5-dev \
    qtdeclarative5-dev \
    libqt5opengl5-dev \
    libqt5texttospeech5-dev \
    qtpositioning5-dev \
    qt3d5-dev \
    qt3d5-dev-tools \
    libqt5charts5-dev \
    libqt5svg5-dev \
    qtwebengine5-dev \
    qml-module-qtquick-controls \
    qml-module-qtcharts \
    mesa-common-dev \
    freeglut3-dev \
    libpng-dev \
    libsdl2-dev \
    libsdl2-net-dev \
    libsdl2-mixer-dev \
    libsdl2-image-dev \
    libsdl2-ttf-dev \
    libglew-dev \
    libgl-dev \
    apache2 \
    libuv1-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/*

# Create /opt/raylib directory
RUN mkdir -p /opt/raylib

# Clone and build raylib
WORKDIR /opt/raylib
RUN wget -q https://github.com/raysan5/raylib/archive/refs/tags/5.0.zip \
    && unzip -q 5.0.zip \
    && cd raylib-5.0 \
    && cmake -B build -DBUILD_SHARED_LIBS=ON -DBUILD_EXAMPLES=OFF -DCMAKE_BUILD_TYPE=Release -GNinja \
    && cmake --build build \
    && cmake --install build

# Create /opt/tilengine directory
RUN mkdir -p /opt/tilengine

# Clone and build tilengine
WORKDIR /opt/tilengine
RUN git clone --depth 1 -q https://github.com/megamarc/Tilengine . \
    && cd src \
    && make -j$(nproc)  \
    && cd ../ \
    && ./install \
    && mv /usr/lib/libTilengine.so /usr/lib/libtilengine.so \
    && mv /usr/include/Tilengine.h /usr/include/tilengine.h

# Create /opt/libui-ng directory
RUN mkdir -p /opt/libui-ng

# Clone and build libui-ng
WORKDIR /opt/libui-ng
RUN git clone --depth 1 -q https://github.com/libui-ng/libui-ng . \
    && meson setup build \
    && ninja -C build  \
    && ninja -C build install

# Clean up
RUN rm -rf /opt/raylib /opt/tilengine /opt/libui-ng

# Create /opt/ring directory
RUN mkdir -p /opt/ring

# Clone and build Ring
WORKDIR /opt/ring
RUN git clone --depth 1 --branch "v$RING_VERSION" -q https://github.com/ring-lang/ring .

COPY patches/ringpdfgen.patch .
COPY patches/ringfastpro.patch .

# Check the RING_VERSION and apply patches if it's under 1.22
RUN if [ "$(echo "$RING_VERSION < 1.22" | bc)" -eq 1 ]; then \
        git apply ringpdfgen.patch && \
        git apply ringfastpro.patch; \
    fi

RUN find . -type f -name "*.sh" -exec sed -i 's/\bsudo\b//g' {} + \
    && find . -type f -name "*.sh" -exec sed -i 's/-L \/usr\/lib\/i386-linux-gnu//g' {} + \
    && find extensions/ringqt -name "*.sh" -exec sed -i 's/\bmake\b/make -j$(nproc)/g' {} + \
    && rm -rf extensions/ringraylib5/src/inux_raylib-5 \
    && rm -rf extensions/ringtilengine/linux_tilengine \
    && rm -rf extensions/ringlibui/linux \
    && sed -i 's/ -I linux_raylib-5\/include//g; s/ -L $PWD\/linux_raylib-5\/lib//g' extensions/ringraylib5/src/buildgcc.sh \
    && sed -i '/extensions\/ringraylib5\/src\/linux/d' bin/install.sh \
    && sed -i 's/ -I linux_tilengine\/include//g; s/ -L $PWD\/linux_tilengine\/lib//g' extensions/ringtilengine/buildgcc.sh \
    && sed -i '/extensions\/ringtilengine/d' bin/install.sh \
    && sed -i 's/ -I linux//g; s/ -L \$PWD\/linux//g' extensions/ringlibui/buildgcc.sh \
    && sed -i '/extensions\/ringlibui\/linux/d' bin/install.sh \
    && sed -i 's/-L \/usr\/local\/pgsql\/lib//g' extensions/ringpostgresql/buildgcc.sh \
    && cd build \
    && bash buildgcc.sh -ring -ringallegro -ringfreeglut -ringmurmurhash -ringqt-core -ringqt-light -ringqt -ringstbimage -ringzip -ringhttplib -ringmysql -ringraylib -ringtilengine -ringthreads -ringcjson -ringinternet -ringodbc -ringrogueutil -ringpdfgen -ringconsolecolors -ringlibui -ringopengl -ringsdl -ringcurl -ringlibuv -ringopenssl -ringsockets -ringfastpro -ringpostgresql -ringsqlite -ring2exe -ringpm

# Reduce image size by removing unnecessary directories
RUN rm -rf applications documents marketing samples tools/{editors,formdesigner,help2wiki,ringnotepad,tryringonline}

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the working directory
WORKDIR /app

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
