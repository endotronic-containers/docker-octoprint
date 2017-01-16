FROM ubuntu:xenial

ENV OCTOPRINT_VERSION=1.2.6
ENV CURA_ENGINE_VERSION=15.04.6
ENV M33FIO_BRANCH devel

RUN set -xe \
  && echo "Setup Temporary packages for compilation" \
  && export PKGS='build-essential subversion libjpeg-dev zlib1g-dev libv4l-dev wget unzip git python python-pip python-dev libyaml-dev python-pygame python-serial' \
  && echo "Installing Dependencies" \
  && apt-get update \
  && apt-get install -y libprotobuf9v5 libav-tools avrdude libjpeg-turbo8 curl imagemagick psmisc --no-install-recommends \
  && apt-get install -y ${PKGS} --no-install-recommends \
  && echo "Download OctoPrint/CuraEngine/mjpg-streamer" \
  && cd /tmp/ \
  && wget https://github.com/foosel/OctoPrint/archive/${OCTOPRINT_VERSION}.tar.gz \
  && wget https://github.com/Ultimaker/CuraEngine/archive/${CURA_ENGINE_VERSION}.tar.gz \
  && wget https://sourceforge.net/code-snapshots/svn/m/mj/mjpg-streamer/code/mjpg-streamer-code-182.zip \
  && echo "Installing mjpg-streamer" \
  && unzip mjpg-streamer-code-182.zip \
  && cd mjpg-streamer-code-182/mjpg-streamer \
  && make \
  && make install \
  && cd ../.. \
  && echo "Installing CuraEngine" \
  && tar -zxf ${CURA_ENGINE_VERSION}.tar.gz \
  && cd CuraEngine-${CURA_ENGINE_VERSION} \
  && mkdir build \
  && make \
  && mv -f ./build /CuraEngine/ \
  && cd .. \
  && echo "Installing OctoPrint" \
  && tar -zxf ${OCTOPRINT_VERSION}.tar.gz \
  && mv -f OctoPrint-${OCTOPRINT_VERSION} /octoprint/ \
  && cd /octoprint/ \
  && echo "Install OctoPrint requirements" \
  && pip install pip --upgrade \
  && pip install setuptools --upgrade \
  && pip install regex --upgrade \
  && pip install pillow --upgrade \
  && python setup.py install \
  && wget https://github.com/donovan6000/M33-Fio/archive/${M33FIO_BRANCH}.zip -O m33fio.zip \
  && pip install m33fio.zip \
  && echo "Cleaning Temporary Packages + Installation leftovers" \
  && apt-get purge -y --auto-remove \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* /var/tmp/*

EXPOSE 5000

VOLUME /data
WORKDIR /data

ADD octoprint.sh /usr/bin/
ENV YUV_CAMERA "true"

ENTRYPOINT ["bash", "/usr/bin/octoprint.sh"]