FROM lsiobase/nginx:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
ARG AKAUNTING_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	composer \
	curl \
	git \
	nodejs \
	npm && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	php7 \
	php7-curl \
	php7-dom \
	php7-pdo_mysql \
	php7-tokenizer \
	php7-zip && \
 echo "**** install akaunting ****" && \
 mkdir -p /app/akaunting && \
 if [ -z ${akaunting_RELEASE+x} ]; then \
	akaunting_RELEASE=$(curl -sX GET "https://api.github.com/repos/akaunting/akaunting/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/akaunting.tar.gz -L \
	"https://github.com/akaunting/akaunting/archive/${akaunting_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/akaunting.tar.gz -C \
	/app/akaunting/ --strip-components=1 && \
 echo "**** install composer packages ****" && \
 cd /app/akaunting && \
 composer install \
	--no-dev \
	--no-suggest \
	--no-interaction && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /
