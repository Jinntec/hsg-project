# syntax=docker/dockerfile:1
# Images
ARG EXISTDB_VERSION=experimental
ARG BUILDER_IMAGE=ghcr.io/eeditiones/builder:latest

# Dependency Versions
ARG PUBLISHER_LIB_VERSION=6.1.2
ARG JINKS_TEMPLATES_VERSION=1.4.2
ARG CRYPTO_VERSION=7.0.0

# Bust "latest" release downloads on schedule / workflow_dispatch (see workflow).
ARG CACHE_DATE=static

# xars are architecture-independent: build them once on the host platform
# instead of repeating `ant xar` under QEMU for every target platform
FROM --platform=$BUILDPLATFORM ${BUILDER_IMAGE} AS build

# URL
ARG PUBLIC_REPO=https://exist-db.org/exist/apps/public-repo/public
ARG HSG_GIT=https://github.com/HistoryAtState

# Inherited
ARG PUBLISHER_LIB_VERSION
ARG JINKS_TEMPLATES_VERSION
ARG CRYPTO_VERSION
ARG CACHE_DATE

# Copy expath dependencies and ensure proper installation order
WORKDIR /tmp/deps
ADD --link ${PUBLIC_REPO}/expath-crypto-module-${CRYPTO_VERSION}.xar  001-crypto.xar
ADD --link ${PUBLIC_REPO}/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar  002-tp-lib.xar
ADD --link ${PUBLIC_REPO}/jinks-templates-${JINKS_TEMPLATES_VERSION}.xar 003-ji-tmpl.xar
# : "${CACHE_DATE}" binds the arg so schedule rebuilds re-fetch this and the
# HSG "latest" ADDs below. GIT_AUTH_TOKEN raises GitHub API rate limits in CI.
RUN --mount=type=secret,id=GIT_AUTH_TOKEN,env=GH_TOKEN \
    : "${CACHE_DATE}" \
    && gh release download -R HistoryAtState/hsg-jinks -p 'hsg-jinks-*.xar' -O 004-hsg-jinks.xar

# Copy HSG Deps should be sorted in ascending order according to update frequency
ADD --link ${HSG_GIT}/gsh/releases/latest/download/gsh.xar gsh.xar
ADD --link ${HSG_GIT}/carousel/releases/latest/download/carousel.xar carousel.xar
ADD --link ${HSG_GIT}/aws.xq/releases/latest/download/aws-xq.xar aws-xq.xar
ADD --link ${HSG_GIT}/administrative-timeline/releases/latest/download/administrative-timeline.xar administrative-timeline.xar
ADD --link ${HSG_GIT}/conferences/releases/latest/download/conferences.xar conferences.xar
ADD --link ${HSG_GIT}/frus-history/releases/latest/download/frus-history.xar frus-history.xar
ADD --link ${HSG_GIT}/hac/releases/latest/download/hac.xar hac.xar
ADD --link ${HSG_GIT}/milestones/releases/latest/download/milestones.xar milestones.xar
ADD --link ${HSG_GIT}/other-publications/releases/latest/download/other-publications.xar other-publications.xar
ADD --link ${HSG_GIT}/pocom/releases/latest/download/pocom.xar pocom.xar
ADD --link ${HSG_GIT}/rdcr/releases/latest/download/rdcr.xar rdcr.xar
ADD --link ${HSG_GIT}/tags/releases/latest/download/tags.xar tags.xar
ADD --link ${HSG_GIT}/travels/releases/latest/download/travels.xar travels.xar
ADD --link ${HSG_GIT}/visits/releases/latest/download/visits.xar visits.xar
ADD --link ${HSG_GIT}/wwdai/releases/latest/download/wwdai.xar wwdai.xar
ADD --link ${HSG_GIT}/frus-tei/releases/latest/download/frus-tei.xar frus-tei.xar

# pre-populate the database by launching it once
FROM duncdrum/existdb:${EXISTDB_VERSION} AS populate

COPY --from=build /tmp/deps/*.xar /exist/autodeploy/
RUN [ "java", "org.exist.start.Main", "client", "--no-gui",  "-l", "-u", "admin", "-P", "", "-x", "system:get-version()" ]

FROM duncdrum/existdb:${EXISTDB_VERSION}

COPY --from=build /tmp/deps/*.xar /exist/autodeploy/
# Only the populated data is carried over. Lucene's NativeFSLock compares the
# creation time of write.lock; a stale lock from an image layer is copied up by
# overlayfs at runtime, the time changes, and eXist fails to boot with an
# AlreadyClosedException. Lucene recreates the locks on first start.
COPY --from=populate --exclude=**/write.lock /exist/data /exist/data

# The labels inherited from the base image (title, source, version, created)
# describe distroless-exist, not this image. revision, created and version are
# set at build time by the workflow.
LABEL org.opencontainers.image.title="hsg-project" \
      org.opencontainers.image.description="eXist-db pre-populated with the History at State (HSG) packages" \
      org.opencontainers.image.source="https://github.com/Jinntec/hsg-project" \
      org.opencontainers.image.url="https://github.com/Jinntec/hsg-project"

# Same probe as the base image. Without --interval docker waits 30s before the
# first result, although the server is up within seconds from the pre-populated
# data. Exec form only, so it also works without a shell or curl.
HEALTHCHECK --interval=10s --timeout=30s --start-period=60s --retries=3 \
    CMD ["java", "org.exist.start.Main", "client", "--no-gui", "--user", "guest", "--password", "guest", "--xpath", "system:get-version()"]
