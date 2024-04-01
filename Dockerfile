FROM duncdrum/existdb:6.2.0

# Dependency Versions
ARG TEMPLATING_VERSION=1.1.0
ARG TEI_PUBLISHER_LIB_VERSION=2.10.1
ARG EXPATH_CRYPTO_VERSION=6.0.1

# Copy expath dependencies and ensure proper installation order
ADD https://exist-db.org/exist/apps/public-repo/public/shared-resources-0.9.1.xar /exist/autodeploy/000.xar
ADD https://exist-db.org/exist/apps/public-repo/public/expath-crypto-module-${EXPATH_CRYPTO_VERSION}.xar  /exist/autodeploy/001.xar
ADD http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar /exist/autodeploy/002.xar
ADD https://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${TEI_PUBLISHER_LIB_VERSION}.xar  /exist/autodeploy/003.xar


# Copy HSH Deps should be sorted in ascending order according to update frequency
ADD https://github.com/joewiz/gsh/releases/download/v0.4.0/gsh-0.4.0.xar  /exist/autodeploy/
ADD https://github.com/HistoryAtState/aws.xq/releases/download/v1.0.1/aws-xq-1.0.1.xar /exist/autodeploy/
# TODO determine the requirment for above two project xars
ADD https://github.com/HistoryAtState/administrative-timeline/releases/download/v0.4.1/administrative-timeline-0.4.1.xar  /exist/autodeploy/
ADD https://github.com/HistoryAtState/carousel/releases/download/v0.8.1/carousel-0.8.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/conferences/releases/download/v0.9.1/conferences-0.9.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/frus-history/releases/download/v0.4.1/frus-history-0.4.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/hac/releases/download/v1.0.2/hac-1.0.2.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/hsg-shell/releases/download/v3.0.1/hsg-shell-3.0.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/milestones/releases/download/v0.4.1/milestones-0.4.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/other-publications/releases/download/v0.4.1/other-publications-0.4.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/pocom/releases/download/v0.5.1/pocom-0.5.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/rdcr/releases/download/v0.5.1/rdcr-0.5.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/release/releases/download/0.5.1/release-0.5.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/tags/releases/download/v1.0.1/tags-1.0.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/terms/releases/download/v0.4.1/terms-0.4.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/travels/releases/download/v0.4.1/travels-0.4.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/visits/releases/download/v0.4.1/visits-0.4.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/wwdai/releases/download/v0.4.1/wwdai-0.4.1.xar /exist/autodeploy/
ADD https://github.com/HistoryAtState/frus/releases/download/v0.5.3/frus-0.5.3.xar /exist/autodeploy/

# pre-populate the database by launching it once and change default pw
RUN [ "java", "org.exist.start.Main", "client", "--no-gui",  "-l", "-u", "admin", "-P", "" ]