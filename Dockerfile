FROM duncdrum/existdb:6.2.0

# Dependency Versions
ARG TEMPLATING_VERSION=1.1.0
ARG TEI_PUBLISHER_LIB_VERSION=2.10.1
ARG EXPATH_CRYPTO_VERSION=6.0.1

# Copy expath dependencies and ensure proper installation order
ADD --link https://exist-db.org/exist/apps/public-repo/public/shared-resources-0.9.1.xar /exist/autodeploy/000.xar
ADD --link https://exist-db.org/exist/apps/public-repo/public/expath-crypto-module-${EXPATH_CRYPTO_VERSION}.xar  /exist/autodeploy/001.xar
ADD --link http://exist-db.org/exist/apps/public-repo/public/templating-${TEMPLATING_VERSION}.xar /exist/autodeploy/002.xar
ADD --link https://exist-db.org/exist/apps/public-repo/public/tei-publisher-lib-${TEI_PUBLISHER_LIB_VERSION}.xar  /exist/autodeploy/003.xar


# Copy HSH Deps should be sorted in ascending order according to update frequency
ADD --link https://github.com/joewiz/gsh/releases/download/latest/gsh.xar  /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/aws.xq/releases/download/latest/aws-xq.xar /exist/autodeploy/
# TODO determine the requirment for above two project xars
ADD --link https://github.com/HistoryAtState/administrative-timeline/releases/latest/download/administrative-timeline.xar  /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/carousel/releases/latest/download/carousel.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/conferences/releases/latest/download/conferences.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/frus-history/releases/latest/download/frus-history.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/hac/releases/latest/download/hac.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/hsg-shell/releases/latest/download/hsg-shell.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/milestones/releases/latest/download/milestones.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/other-publications/releases/latest/download/other-publications.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/pocom/releases/latest/download/pocom.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/rdcr/releases/latest/download/rdcr.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/release/releases/latest/download/release.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/tags/releases/latest/download/tags.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/terms/releases/latest/download/terms.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/travels/releases/latest/download/travels.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/visits/releases/latest/download/visits.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/wwdai/releases/latest/download/wwdai.xar /exist/autodeploy/
ADD --link https://github.com/HistoryAtState/frus/releases/latest/download/frus.xar /exist/autodeploy/

# pre-populate the database by launching it once and change default pw
RUN [ "java", "org.exist.start.Main", "client", "--no-gui",  "-l", "-u", "admin", "-P", "" ]