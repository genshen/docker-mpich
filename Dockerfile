# docker build --rm=true -t genshen/mpich:3.2.1 .
FROM alpine:latest AS mpich_builder

ARG REQUIRE="build-base gfortran"
#  apk update && apk upgrade
RUN apk add --no-cache ${REQUIRE}

#### INSTALL MPICH ####
# Source is available at http://www.mpich.org/static/downloads/

# Build Options:
# See installation guide of target MPICH version
# Ex: http://www.mpich.org/static/downloads/3.2.1/mpich-3.2.1-installguide.pdf
# These options are passed to the steps below
ARG MPICH_SRC_DIR="/tmp/mpich-3.2.1"
ARG MPICH_VERSION="3.2.1"
ARG MPICH_CONFIGURE_OPTIONS="--prefix=/usr/local/mpi-3.2.1"
ARG MPICH_MAKE_OPTIONS="-j4"

# Download, build, and install MPICH
WORKDIR ${MPICH_SRC_DIR}
RUN wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz \
    && tar xfz mpich-${MPICH_VERSION}.tar.gz  \
    && cd mpich-${MPICH_VERSION}  \
    && ./configure ${MPICH_CONFIGURE_OPTIONS}  \
    && make ${MPICH_MAKE_OPTIONS} && make install \
    && rm -rf ${MPICH_SRC_DIR}


FROM alpine:latest

LABEL maintainer="genshen genshenchu@gmail.com" \
      description="MPI development environment,including mpich,gcc,g++,gfortran,make."

#### ADD DEFAULT USER ####
ARG USER=mpi
ENV USER_HOME="/home/${USER}"  WORKDIR="/project"  MPI_HOME=/usr/local/mpi-3.2.1

COPY --from=mpich_builder /usr/local/mpi-3.2.1  /usr/local/mpi-3.2.1

# build-base including gcc g++ make libc-dev binutils fortift-headers.
RUN apk add --no-cache build-base sudo gfortran \
    && mkdir -p /usr/local/include  /usr/local/bin  /usr/local/lib  \
    && cd /usr/local/bin && ln -s ${MPI_HOME}/bin/* ./    \
    && cd /usr/local/include && ln -s ${MPI_HOME}/include/* ./   \
    && cd /usr/local/lib && ln -s ${MPI_HOME}/lib/* ./  \
    && adduser -D ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && chown -R ${USER}:${USER} ${USER_HOME} \
    && mkdir ${WORKDIR} \
    && chown -R ${USER}:${USER} ${WORKDIR}

WORKDIR ${WORKDIR}
USER ${USER}

# CMD ["/bin/ash"]  # default is /bin/sh
