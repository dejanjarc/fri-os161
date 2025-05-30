# Dockerfile for OS/161 version 2.0.3

# --- Base container --- #
FROM ubuntu:20.04 AS base

ARG MIRROR="http://www.os161.org/download/"
ARG INSTALL_DIR="/usr/local/os161"

ENV MIRROR=${MIRROR}
ENV INSTALL_DIR=${INSTALL_DIR}

# Set shell to bash with pipefail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Dependency installs + clean up
RUN apt-get --yes update && \
    apt-get install --yes --no-install-recommends \
        bmake \
        build-essential \
        curl \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libncurses-dev \
        nano \
        sudo 
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Toolchain builder container --- #
FROM base AS builder

# This toolchain is based on the OS/161 2.0.3 release
# and is compatible with the OS/161 2.0.3 kernel source.

ARG BINUTILS_161="binutils-2.24+os161-2.1"
ARG GCC_161="gcc-4.8.3+os161-2.1"
ARG GDB_161="gdb-7.8+os161-2.1"
ARG SYS_161="sys161-2.0.8"
ARG BUILD_DIR="/tmp/os161"

# Download and extract toolchain tarballs
RUN mkdir -p "${BUILD_DIR}" && cd ${BUILD_DIR} && \
    curl "${MIRROR}/${BINUTILS_161}.tar.gz" | tar -xz && \
    curl "${MIRROR}/${GCC_161}.tar.gz" | tar -xz && \
    curl "${MIRROR}/${GDB_161}.tar.gz" | tar -xz && \
    curl "${MIRROR}/${SYS_161}.tar.gz" | tar -xz

# Build toolchain
COPY "build-toolchain.sh" "patches" "${BUILD_DIR}/"
RUN cd "${BUILD_DIR}" && \
    ./build-toolchain.sh \
        -u "${BINUTILS_161}" \
        -c "${GCC_161}" \
        -d "${GDB_161}" \
        -s "${SYS_161}" \
        -i "${INSTALL_DIR}" \
        -b "${BUILD_DIR}"

# --- Runner container --- #
FROM base AS runner

ARG USERNAME="os161"
ARG USER_HOME="/home/${USERNAME}"
ARG OS_161_ROOT="${USER_HOME}"
ARG OS_161_TOOLCHAIN="${OS_161_ROOT}/tools"
ARG OS_161_SRC="${OS_161_ROOT}/src"
ARG OS_161_INSTALL="${OS_161_ROOT}/root"
ARG OS_161="os161-base-2.0.3"

ENV PATH="${OS_161_TOOLCHAIN}/bin:${PATH}"

# Create and set user
RUN useradd --create-home --home-dir "${USER_HOME}" --shell=/bin/bash --user-group "${USERNAME}" --groups sudo && \
    mkdir -p "${OS_161_ROOT}" && \
    chown "${USERNAME}:${USERNAME}" "${OS_161_ROOT}" && \
    echo "${USERNAME}:os161" | chpasswd
USER ${USERNAME}

# Copy toolchain binaries and links from builder stage
COPY --chown=${USERNAME} --from=builder "${INSTALL_DIR}" "${OS_161_TOOLCHAIN}/"

# Download and compile kernel source
COPY --chown=${USERNAME} "build-kernel.sh" ".gdbinit.main" ".gdbinit.root" "${OS_161_ROOT}/"
RUN cd "${OS_161_ROOT}" && \
    curl "${MIRROR}/${OS_161}.tar.gz" | tar -xz && mv "${OS_161}" "${OS_161_SRC}" && \
    ./build-kernel.sh \
        -c "DUMBVM" \
        -s "${OS_161_SRC}" \
        -i "${OS_161_INSTALL}" && \
    cp "${OS_161_TOOLCHAIN}/share/examples/sys161/sys161.conf.sample" "${OS_161_INSTALL}/sys161.conf" && \
    mv ".gdbinit.main" "${USER_HOME}/.gdbinit" && \
    mv ".gdbinit.root" "${OS_161_INSTALL}/.gdbinit"  && \
    rm "build-kernel.sh"

# Create symbolic links for OS/161 tools
RUN cd "${OS_161_ROOT}/tools/bin" && \
    sh -c 'for i in mips-*; do ln -s $i os161-`echo $i | cut -d- -f4-`; done'

# Set working directory
WORKDIR ${USER_HOME}

# Set default container executable
CMD ["/bin/bash"]