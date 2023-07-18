FROM quay.io/pypa/manylinux_2_28_aarch64 as builder

# Build jaxlib from source.
# https://jax.readthedocs.io/en/latest/developer.html#building-jaxlib-from-source

ARG PYTHON_VERSION
ARG JAXLIB_VERSION

RUN ln -s /opt/python/cp${PYTHON_VERSION}-cp${PYTHON_VERSION}/bin/pip /usr/local/bin/pip \
    && ln -s /opt/python/cp${PYTHON_VERSION}-cp${PYTHON_VERSION}/bin/python /usr/local/bin/python

RUN pip install numpy wheel build

WORKDIR /builder

COPY . .

RUN python build/build.py

RUN auditwheel repair dist/jaxlib-${JAXLIB_VERSION}-cp${PYTHON_VERSION}-none-manylinux_2_28_aarch64.whl

FROM scratch

# Copy build output
COPY --from=builder /builder/dist /
