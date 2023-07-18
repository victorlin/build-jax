# Setup: pull cross-compilation tools.
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

FROM --platform=$BUILDPLATFORM python:3.10-slim-bullseye as builder

# Copy cross-compilation tools.
COPY --from=xx / /

# Build jaxlib from source.
# https://jax.readthedocs.io/en/latest/developer.html#building-jaxlib-from-source

ARG PYTHON_VERSION
ARG JAXLIB_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends crossbuild-essential-arm64

RUN xx-apt-get install -y \
    gcc \
    g++

RUN pip install numpy wheel build

WORKDIR /builder

COPY . .

RUN python build/build.py  --bazel_option=--crosstool_top=//toolchain:toolchain --target_cpu=aarch64 --bazel_options=--override_repository=org_tensorflow=/path/to/the/tensorflow/checkout

RUN auditwheel repair dist/jaxlib-${JAXLIB_VERSION}-cp${PYTHON_VERSION}-none-manylinux_2_28_aarch64.whl

FROM scratch

# Copy build output
COPY --from=builder /builder/dist /
