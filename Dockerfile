# Use Debian latest as the base image
FROM debian:latest

# Set environment variables to reduce interaction during package installation
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install necessary packages
RUN apt-get update && apt-get install -y -qq --no-install-recommends \
    build-essential \
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
    apache2 \
    libuv1-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/*

# Create /opt/ring directory
RUN mkdir -p /opt/ring

# Clone and build Ring
WORKDIR /opt/ring
RUN git clone --depth 1 --branch v1.21.2 https://github.com/ring-lang/ring . \
    && find . -type f -name "*.sh" -exec sed -i 's/\bsudo\b//g' {} + \
    && find extensions/ringqt -name "*.sh" -exec sed -i 's/\bmake\b/make -j$(nproc)/g' {} + \
    && cd build \
    && bash buildgcc.sh

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the working directory
WORKDIR /app

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]