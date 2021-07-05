# Dockerfile for xray based alpine
# Copyright (C) 2019 - 2020 Teddysun <i@teddysun.com>
# Copyright (c) 2021 Chen Jicheng <hi@chenjicheng.com>
# Reference URL:
# https://github.com/XTLS/Xray-core
# https://github.com/v2fly/v2ray-core
# https://github.com/v2fly/geoip
# https://github.com/v2fly/domain-list-community

FROM --platform=${TARGETPLATFORM} alpine:latest as build

ARG TARGETPLATFORM

WORKDIR /build

COPY xray.sh .

COPY config.json /etc/xray/config.json

RUN set -ex \
    && apk add --no-cache unzip ca-certificates \
    && sh xray.sh "${TARGETPLATFORM}" \
    && rm -fv xray.sh \
    && unzip xray.zip \
    && wget -O geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat \
    && wget -O geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

FROM --platform=${TARGETPLATFORM} alpine:latest as xray

ARG TARGETPLATFORM

COPY --from=build /build/xray /usr/bin/xray
COPY --from=build /build/geosite.dat /usr/local/share/xray/geosite.dat
COPY --from=build /build/geoip.dat /usr/local/share/xray/geoip.dat

#RUN set -ex \
#    && mkdir -p /var/log/xray /usr/local/share/xray 

VOLUME /etc/xray
CMD [ "/usr/bin/xray", "run", "-confdir", "/etc/xray" ]
