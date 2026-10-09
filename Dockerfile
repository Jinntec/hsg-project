# Images
ARG EXISTDB_VERSION=experimental
ARG BUILDER_IMAGE=ghcr.io/eeditiones/builder:latest

# Branch
ARG VEC_REF=feat/hsg-embedding-vector-field

# Dependency Versions
ARG PUBLISHER_LIB_VERSION=6.1.2
ARG JINKS_TEMPLATES_VERSION=1.4.2
ARG CRYPTO_VERSION=7.0.0
ARG JWT_VERSION=2.0.2

FROM ${BUILDER_IMAGE} AS build

# URL
ARG PUBLIC_REPO=https://exist-db.org/exist/apps/public-repo/public
ARG HSG_GIT=https://github.com/HistoryAtState

# Inherited
ARG VEC_REF
ARG PUBLISHER_LIB_VERSION
ARG JINKS_TEMPLATES_VERSION
ARG CRYPTO_VERSION
ARG JWT_VERSION


# Copy expath dependencies and ensure proper installation order
WORKDIR /tmp/deps
ADD --link ${PUBLIC_REPO}/expath-crypto-module-${CRYPTO_VERSION}.xar  001-crypto.xar
ADD --link ${PUBLIC_REPO}/tei-publisher-lib-${PUBLISHER_LIB_VERSION}.xar  002-tp-lib.xar
ADD --link ${PUBLIC_REPO}/jinks-templates-${JINKS_TEMPLATES_VERSION}.xar 003-ji-tmpl.xar
ADD --link ${PUBLIC_REPO}/jwt-${JWT_VERSION}.xar 004-jwt.xar


# TODO determine the requirment for these project xars
# ADD --link ${HSG_GIT}/release/releases/latest/download/release.xar release.xar
# ADD --link ${HSG_GIT}/terms/releases/latest/download/terms.xar terms.xar
# ADD --link ${HSG_GIT}/hsg-shell/releases/latest/download/hsg-shell.xar hsg-shell.xar
# ADD --link ${HSG_GIT}/frus/releases/latest/download/frus.xar frus.xar

# Copy HSG Deps should be sorted in ascending order according to update frequency
ADD --link ${HSG_GIT}/gsh/releases/latest/download/gsh.xar gsh.xar
ADD --link ${HSG_GIT}/carousel/releases/latest/download/carousel.xar carousel.xar
ADD --link ${HSG_GIT}/aws.xq/releases/latest/download/aws-xq.xar aws-xq.xar
ADD --link ${HSG_GIT}/administrative-timeline/releases/latest/download/administrative-timeline.xar administrative-timeline.xar

# ADD --link ${HSG_GIT}/conferences/releases/latest/download/conferences.xar conferences.xar
# ADD --link ${HSG_GIT}/frus-history/releases/latest/download/frus-history.xar frus-history.xar
# ADD --link ${HSG_GIT}/hac/releases/latest/download/hac.xar hac.xar
# ADD --link ${HSG_GIT}/milestones/releases/latest/download/milestones.xar milestones.xar
# ADD --link ${HSG_GIT}/other-publications/releases/latest/download/other-publications.xar other-publications.xar
# ADD --link ${HSG_GIT}/pocom/releases/latest/download/pocom.xar pocom.xar
# ADD --link ${HSG_GIT}/rdcr/releases/latest/download/rdcr.xar rdcr.xar
ADD --link ${HSG_GIT}/tags/releases/latest/download/tags.xar tags.xar
# ADD --link ${HSG_GIT}/travels/releases/latest/download/travels.xar travels.xar
# ADD --link ${HSG_GIT}/visits/releases/latest/download/visits.xar visits.xar
# ADD --link ${HSG_GIT}/wwdai/releases/latest/download/wwdai.xar wwdai.xar


# PR builds
WORKDIR /tmp
ADD --link ${HSG_GIT}/conferences.git#${VEC_REF} conferences/
ADD --link ${HSG_GIT}/frus-history.git#${VEC_REF} frus-history/
ADD --link ${HSG_GIT}/hac.git#${VEC_REF} hac/
ADD --link ${HSG_GIT}/milestones.git#${VEC_REF} milestones/
ADD --link ${HSG_GIT}/other-publications.git#${VEC_REF} other-publications/
ADD --link ${HSG_GIT}/pocom.git#${VEC_REF} pocom/
ADD --link ${HSG_GIT}/rdcr.git#${VEC_REF} rdcr/
ADD --link ${HSG_GIT}/travels.git#${VEC_REF} travels/
ADD --link ${HSG_GIT}/visits.git#${VEC_REF} visits/
ADD --link ${HSG_GIT}/wwdai.git#${VEC_REF} wwdai/

RUN set -e; i=5; \
    for d in conferences frus-history hac milestones other-publications pocom rdcr travels visits wwdai; do \
      (cd "$d" && ant xar); \
      cp "$d"/build/*.xar "/tmp/deps/$(printf '%03d' "$i")-$d.xar"; \
      i=$((i+1)); \
    done

# Private repos (need --secret id=GIT_AUTH_TOKEN at build time)
# back to master or release artifacts after HistoryAtState/hsg-jinks#74 is merged
ADD --link ${HSG_GIT}/hsg-jinks.git#feat/semantic-search-mvp hsg-jinks/
RUN cd hsg-jinks && ant xar \
    && cp build/*.xar /tmp/deps/015-hsg-jinks.xar

# ant xar-full for when things are more stable
ADD --link ${HSG_GIT}/hsg-jinks-data.git#${VEC_REF} hsg-jinks-data/
RUN cd hsg-jinks-data && ant xar \
    && cp build/*.xar /tmp/deps/016-hsg-jinks-data.xar

FROM duncdrum/existdb:${EXISTDB_VERSION}

COPY --from=build /tmp/deps/*.xar /exist/autodeploy/
# pre-populate the database by launching it once
RUN [ "java", "org.exist.start.Main", "client", "--no-gui",  "-l", "-u", "admin", "-P", "", "-x", "system:get-version()" ]
