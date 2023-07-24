FROM ubuntu:jammy
ARG NFPM_VER=2.32.0

# install curl
RUN apt-get update
RUN apt-get -y install curl ca-certificates gcc make dpkg-dev lintian

# install nfpm
RUN mkdir -p /work
WORKDIR /work
RUN curl -sSLO https://github.com/goreleaser/nfpm/releases/download/v${NFPM_VER}/nfpm_${NFPM_VER}_amd64.deb
RUN dpkg -i nfpm_${NFPM_VER}_amd64.deb

# download pg_statsinfo source tarball
RUN mkdir -p /work/pikchr
RUN curl -sSLo /work/pikchr/pikchr.c 'https://pikchr.org/home/raw/da1b3e3f2126776a4ebb4a1acd5ec2b943d263a6e3c5bde257a9668cc1fe9a86?at=da1b3e3f21'

# build and install
WORKDIR /work/pikchr
RUN gcc -O2 -g -Wall -Wextra -DPIKCHR_SHELL -o pikchr pikchr.c -lm
RUN install -D pikchr /work/install/usr/bin/pikchr
RUN strip --strip-unneeded --remove-section=.comment --remove-section=.note \
      /work/install/usr/bin/pikchr

COPY debian/control /work/pikchr/debian/
RUN dpkg-shlibdeps -Tsubstvars /work/install/usr/bin/pikchr
COPY depends.awk /work/pikchr/

# # build deb package
COPY changelog.yaml nfpm.yaml /work/install/
RUN cat substvars | sed 's/^shlibs:Depends=//' | awk -F ', ' -f depends.awk >> /work/install/nfpm.yaml
WORKDIR /work/install
RUN nfpm package -p deb

RUN lintian *.deb
