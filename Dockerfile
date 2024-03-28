# START STAGE 1
FROM --platform=$BUILDPLATFORM openjdk:8-jdk-slim as builder

USER root

ENV NODE_MAJOR 18
# 14 
ENV ANT_VERSION 1.10.13
ENV ANT_HOME /etc/ant-${ANT_VERSION}

WORKDIR /tmp

ARG TARGETOS TARGETARCH
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    gnupg

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install nodejs -y

RUN curl -L -o apache-ant-${ANT_VERSION}-bin.tar.gz http://www.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && mkdir ant-${ANT_VERSION} \
    && tar -zxvf apache-ant-${ANT_VERSION}-bin.tar.gz \
    && mv apache-ant-${ANT_VERSION} ${ANT_HOME} \
    && rm apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -rf ant-${ANT_VERSION} \
    && rm -rf ${ANT_HOME}/manual \
    && unset ANT_VERSION

ENV PATH ${PATH}:${ANT_HOME}/bin

FROM builder as hsg

# add key
RUN  mkdir -p ~/.ssh && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Required XARs 
ARG TEMPLATING_VERSION=1.1.0
ARG TEI_PUBLISHER_LIB_VERSION=2.10.1
ARG EXPATH_CRYPTO_VERSION=6.0.1

RUN mkdir /tmp/binary-xars

RUN curl -L -o /tmp/binary-xars/00-templating-${TEMPLATING_VERSION}.xar http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar
RUN curl -L -o /tmp/binary-xars/00-tei-publisher-lib-${TEI_PUBLISHER_LIB_VERSION}.xar https://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${TEI_PUBLISHER_LIB_VERSION}.xar
RUN curl -L -o /tmp/binary-xars/00-expath-crypto-module-${EXPATH_CRYPTO_VERSION}.xar https://exist-db.org/exist/apps/public-repo/public/expath-crypto-module-${EXPATH_CRYPTO_VERSION}.xar
RUN curl -L -o /tmp/binary-xars/00-shared-resources-0.9.1.xar https://exist-db.org/exist/apps/public-repo/public/shared-resources-0.9.1.xar
# RUN curl -L -o /tmp/binary-xars/01-tei-pm-1.1.4.xar https://exist-db.org/exist/apps/public-repo/public/tei-pm-1.1.4.xar
RUN curl -L -o /tmp/binary-xars/administrative-timeline-0.4.1.xar https://github.com/HistoryAtState/administrative-timeline/releases/download/v0.4.1/administrative-timeline-0.4.1.xar
RUN curl -L -o /tmp/binary-xars/carousel-0.8.1.xar https://github.com/HistoryAtState/carousel/releases/download/v0.8.1/carousel-0.8.1.xar
RUN curl -L -o /tmp/binary-xars/conferences-0.9.1.xar https://github.com/HistoryAtState/conferences/releases/download/v0.9.1/conferences-0.9.1.xar
RUN curl -L -o /tmp/binary-xars/frus-0.5.3.xar https://github.com/HistoryAtState/frus/releases/download/v0.5.3/frus-0.5.3.xar
RUN curl -L -o /tmp/binary-xars/frus-history-0.4.1.xar https://github.com/HistoryAtState/frus-history/releases/download/v0.4.1/frus-history-0.4.1.xar
RUN curl -L -o /tmp/binary-xars/hac-1.0.2 https://github.com/HistoryAtState/hac/releases/download/v1.0.2/hac-1.0.2.xar
RUN curl -L -o /tmp/binary-xars/hsg-shell-3.0.1.xar https://github.com/HistoryAtState/hsg-shell/releases/download/v3.0.1/hsg-shell-3.0.1.xar
RUN curl -L -o /tmp/binary-xars/milestones-0.4.1.xar https://github.com/HistoryAtState/milestones/releases/download/v0.4.1/milestones-0.4.1.xar
RUN curl -L -o /tmp/binary-xars/other-publications-0.4.1.xar https://github.com/HistoryAtState/other-publications/releases/download/v0.4.1/other-publications-0.4.1.xar
RUN curl -L -o /tmp/binary-xars/pocom-0.5.1.xar https://github.com/HistoryAtState/pocom/releases/download/v0.5.1/pocom-0.5.1.xar
RUN curl -L -o /tmp/binary-xars/rdcr-0.5.1.xar https://github.com/HistoryAtState/rdcr/releases/download/v0.5.1/rdcr-0.5.1.xar
RUN curl -L -o /tmp/binary-xars/release-0.5.1.xar https://github.com/HistoryAtState/release/releases/download/0.5.1/release-0.5.1.xar
RUN curl -L -o /tmp/binary-xars/tags-1.0.1.xar https://github.com/HistoryAtState/tags/releases/download/v1.0.1/tags-1.0.1.xar
RUN curl -L -o /tmp/binary-xars/terms-0.4.1.xar https://github.com/HistoryAtState/terms/releases/download/v0.4.1/terms-0.4.1.xar
RUN curl -L -o /tmp/binary-xars/travels-0.4.1.xar https://github.com/HistoryAtState/travels/releases/download/v0.4.1/travels-0.4.1.xar
RUN curl -L -o /tmp/binary-xars/visits-0.4.1.xar https://github.com/HistoryAtState/visits/releases/download/v0.4.1/visits-0.4.1.xar
RUN curl -L -o /tmp/binary-xars/wwdai-0.4.1.xar https://github.com/HistoryAtState/wwdai/releases/download/v0.4.1/wwdai-0.4.1.xar


# Build XARs from source
RUN git clone --depth 1 -b master https://github.com/joewiz/gsh.git
RUN cd gsh \
     && ant xar

RUN git clone --depth 1 -b master https://github.com/joewiz/s3.git
RUN cd s3 \
     && ant xar

# frus-not-yet-reviewed.git does not build a xar 
# RUN  git clone --depth 1 -b master https://github.com/HistoryAtState/frus-not-yet-reviewed.git
# RUN cd frus-not-yet-reviewed \
#    && ant xar

FROM duncdrum/existdb:6.2.0-debug-j8
COPY --from=hsg /tmp/binary-xars/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/gsh/build/*.xar /exist/autodeploy/
COPY --from=hsg /tmp/s3/build/*.xar /exist/autodeploy/

WORKDIR /exist

# ARG ADMIN_PASS=none

ARG HTTP_PORT=8080
ARG HTTPS_PORT=8443

ENV JAVA_TOOL_OPTIONS \
  -Dfile.encoding=UTF8 \
  -Dsun.jnu.encoding=UTF-8 \
  -Djava.awt.headless=true \
  -Dorg.exist.db-connection.cacheSize=${CACHE_MEM:-256}M \
  -Dorg.exist.db-connection.pool.max=${MAX_BROKER:-20} \
  -Dlog4j.configurationFile=/exist/etc/log4j2.xml \
  -Dexist.home=/exist \
  -Dexist.configurationFile=/exist/etc/conf.xml \
  -Djetty.home=/exist \
  -Dexist.jetty.config=/exist/etc/jetty/standard.enabled-jetty-configs \  
  -XX:+UseG1GC \
  -XX:+UseStringDeduplication \
  -XX:+UseContainerSupport \
  -XX:MaxRAMPercentage=${JVM_MAX_RAM_PERCENTAGE:-75.0} \
  -XX:+ExitOnOutOfMemoryError

# pre-populate the database by launching it once and change default pw
RUN [ "java", "org.exist.start.Main", "client", "--no-gui",  "-l", "-u", "admin", "-P", "" ]

EXPOSE ${HTTP_PORT} ${HTTPS_PORT}