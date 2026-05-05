# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Redis" \
        org.opencontainers.image.description="In memory key value database" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/redis" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-redis/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-redis.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    REDIS_VERSION="8.6.3" \
    REDIS_REPO_URL="https://github.com/redis/redis"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    IMAGE_NAME="nfrastack/redis" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-redis/"

RUN echo "" && \
    REDIS_BUILD_DEPS_ALPINE=" \
                                coreutils \
                                g++ \
                                gcc \
                                linux-headers \
                                make \
                                musl-dev \
                                openssl-dev \
                                tar \
                            " \
                            && \
    \
    REDIS_MODULE_BUILD_DEPS_ALPINE=" \
                                		autoconf \
                                		automake \
                                		bash \
                                		bsd-compat-headers \
                                		build-base \
                                		cargo \
                                		clang21 \
                                		clang21-static \
                                		clang21-libclang \
                                		cmake \
                                		curl \
                                		g++ \
                                		git \
                                		libffi-dev \
                                		libgcc \
                                		libtool \
                                		llvm21-dev \
                                		ncurses-dev \
                                		openssh \
                                		openssl  \
                                		py-virtualenv \
                                		py3-cryptography \
                                		py3-pip \
                                		py3-virtualenv \
                                		python3 \
                                		python3-dev \
                                		rsync \
                                		tar \
                                		unzip \
                                		which \
                                		xsimd \
                                		xz \
                                    " && \
    \
    REDIS_RUN_DEPS_ALPINE=" \
                            setpriv \
                          " \
                          && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user redis 6379 redis 6379 /dev/null && \
    package update && \
    package upgrade && \
    package install \
                        REDIS_BUILD_DEPS \
                        REDIS_MODULE_BUILD_DEPS \
                        REDIS_RUN_DEPS \
                        && \
    \
    PIP_BREAK_SYSTEM_PACKAGES=1 pip install \
                                            -q \
                                                addict \
                                                jinja2 \
                                                ramp-packer \
                                                toml \
                                                && \
	clone_git_repo "${REDIS_REPO_URL}" "${REDIS_VERSION}" && \
	pip install -q --upgrade setuptools &&  pip install -q --upgrade pip && PIP_BREAK_SYSTEM_PACKAGES=1 pip install -q addict toml jinja2 ramp-packer && \
	\
    case "$(container_info arch)" in \
        x86_64) \
            build_arch="x86_64-linux-gnu" ; \
            lg_page="--with-lg-page=12" ;; \
    \
        aarch64) \
            build_arch="aarch64-linux-gnu" ; \
            lg_page="--with-lg-page=16" ;; \
        *) : ;; \
    esac; \
    \
    jemalloc_flags="--build ${build_arch} ${lg_page} --with-lg-hugepage=21" && \
    grep -E '^ *createBoolConfig[(]"protected-mode",.*, *1 *,.*[)],$' src/config.c && \
	sed -ri 's!^( *createBoolConfig[(]"protected-mode",.*, *)1( *,.*[)],)$!\10\2!' src/config.c && \
	grep -E '^ *createBoolConfig[(]"protected-mode",.*, *0 *,.*[)],$' src/config.c && \
	\
    #grep -F 'cd jemalloc && ./configure ' /usr/src/redis/deps/Makefile; \
	#sed -ri 's!cd jemalloc && ./configure !&'"$jemalloc_flags"' !' /usr/src/redis/deps/Makefile && \
	#grep -F "cd jemalloc && ./configure $jemalloc_flags " /usr/src/redis/deps/Makefile && \
	\
    export \
            BUILD_TLS=yes \
            BUILD_WITH_MODULES=yes \
            INSTALL_RUST_TOOLCHAIN=yes \
            DISABLE_WERRORS=yes \
	        PATH="/usr/lib/llvm21/bin:$PATH" \
            RUST_DYN_CRT=1 \
            && \
    \
    make -C /usr/src/redis/modules/redisjson get_source && \
    sed -i 's/^RUST_FLAGS=$/RUST_FLAGS += -C target-feature=-crt-static/' /usr/src/redis/modules/redisjson/src/Makefile && \
    grep -E 'RUST_FLAGS' /usr/src/redis/modules/redisjson/src/Makefile && \
    #make -C /usr/src/redis/modules/redisearch get_source && \
    #sed -i "1i#\!/usr/bin/env bash" /usr/src/redis/modules/redisearch/src/deps/VectorSimilarity/deps/ScalableVectorSearch/cmake/patches/apply_patch_toml.sh && \
    make -j "$(nproc)" all && \
    make install && \
    mkdir -p /data && \
    make -C /usr/src/redis distclean && \
    chown redis:redis /data && \
    container_build_log add "Redis" "${REDIS_VERSION}" "${REDIS_REPO_URL}" && \
    package install \
                        REDIS_RUN_DEPS \
                        SCANNED_RUNTIME_DEPS \
                        && \
    package remove \
                        REDIS_BUILD_DEPS \
                        REDIS_MODULE_BUILD_DEPS \
                        && \
    package cleanup

EXPOSE 6379

COPY rootfs /
