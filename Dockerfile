FROM debian:bullseye-slim as build

RUN apt-get update && apt-get install -y \
    git autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev \
    libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
    patchutils bc zlib1g-dev libexpat-dev ninja-build python-is-python3 \
&& rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone \
    --recurse-submodules=gcc \
    --recurse-submodules=newlib \
    --recurse-submodules=binutils \
    --recurse-submodules=gdb \
    -j4 \
    https://github.com/riscv/riscv-gnu-toolchain

ARG ARCH
ARG ABI

WORKDIR /build/riscv-gnu-toolchain
RUN ./configure --prefix=/opt/riscv --with-arch=$(ARCH) --with-abi=$(ABI) --with-multilib-generator="$ARCH-$ABI--"
RUN make

FROM debian:bullseye-slim
WORKDIR /
COPY --from=build /opt/riscv /opt/riscv
ENV PATH="$PATH:/opt/riscv/bin"
RUN apt-get update && apt-get install -y make libmpc3 && rm -rf /var/lib/apt/lists/*
ENTRYPOINT [ "riscv64-unknown-elf-gcc" ]
