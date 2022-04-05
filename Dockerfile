FROM heroku/heroku:20-build
ARG DEBIAN_FRONTEND=noninteractive

# See env vars below to update package versions
# * $LIBIMAGEMAGICK_VERSION
# * $LIBWEBP_VERSION
# * $LIBHIEF_VERSION
# * $LIBDE265_VERSION

RUN apt-get update && apt-get install -y \
  libheif-dev libjpeg-dev libpng-dev libtiff-dev libgif-dev libomp-dev

ENV PKG_CONFIG_PATH="/usr/src/imagemagick/lib/pkgconfig:$PKG_CONFIG_PATH"

# https://github.com/strukturag/libde265/releases
ENV LIBDE265_VERSION=1.0.8

RUN curl -L https://github.com/strukturag/libde265/releases/download/v$LIBDE265_VERSION/libde265-$LIBDE265_VERSION.tar.gz | tar zx \
  && cd libde265-$LIBDE265_VERSION \
  && ./autogen.sh \
  && ./configure --prefix=/usr/src/imagemagick \
  && make \
  && make install

# https://github.com/strukturag/libheif/releases
ENV LIBHIEF_VERSION=1.12.0

RUN curl -L https://github.com/strukturag/libheif/releases/download/v$LIBHIEF_VERSION/libheif-$LIBHIEF_VERSION.tar.gz | tar zx \
  && cd libheif-$LIBHIEF_VERSION \
  && ./autogen.sh \
  && ./configure --prefix=/usr/src/imagemagick \
  && make \
  && make install

# https://github.com/webmproject/libwebp/tags
ENV LIBWEBP_VERSION=1.2.2

RUN cd /opt \
  &&   curl -L http://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$LIBWEBP_VERSION.tar.gz | tar zx \
  && cd libwebp-$LIBWEBP_VERSION \
  && ./configure  \
  && make \
  && make install


ENV PATH="/usr/src/imagemagick/bin:$PATH:\$PATH"
ENV CPPPATH="/usr/src/imagemagick/include:$CPPPATH"
ENV CPATH="/usr/src/imagemagick/include:$CPATH"
ENV LIBRARY_PATH="/usr/src/imagemagick/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH="/usr/src/imagemagick/lib:$LD_LIBRARY_PATH"

# Remove libwebp from heroku image
RUN ldconfig /usr/src/imagemagick/lib/

# https://imagemagick.org/script/changelog.php
ENV IMAGEMAGICK_VERSION=7.1.0-28

RUN cd /usr/src/ \
  && wget https://imagemagick.org/download/releases/ImageMagick-$IMAGEMAGICK_VERSION.tar.gz \
  && tar xf ImageMagick-$IMAGEMAGICK_VERSION.tar.gz \
  && cd ImageMagick-7* \
  && ./configure --with-heic=yes --with-webp=yes --prefix=/usr/src/imagemagick \
  && make \
  && make install

# Additional copy of libwebp that will be included in the .tar.gz for Heroku
RUN curl -L http://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$LIBWEBP_VERSION.tar.gz | tar zx \
  && cd libwebp-$LIBWEBP_VERSION \
  && ./configure --prefix=/usr/src/imagemagick \
  && make \
  && make install

RUN cd /usr/src/imagemagick \
  && rm -rf build \
  && mkdir build \
  && tar czf \
  /usr/src/imagemagick/build/imagemagick.tar.gz bin include lib
CMD ["tail", "-f", "/dev/null"]
