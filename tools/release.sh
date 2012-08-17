#! /bin/bash

cd `dirname $0`

# Import utilities from common.sh
. ./common.sh

# Clean the build directory
rm -rf $BUILD_DIR_ROOT

# Build the project
cd $SOURCES_DIR
xcodebuild build -configuration Release

BUID_RET=$?
if [ $BUID_RET -ne 0 ]; then
    exit $BUID_RET;
fi

# Packaging
mkdir -p $DIST_DIR
cd $BUILD_DIR_RELEASE

RELEASE_PACKAGE_NAME=${PROJECT}'-'${CURRENT_VERSION_STRING}

# Zip
zip -r ${DIST_DIR}/${RELEASE_PACKAGE_NAME}.zip ${PROJECT}'.'${WRAPPER_EXTENSION}

COMPRESS_RET=$?
if [ $COMPRESS_RET -ne 0 ]; then
    consoleLog "Zip compression failed (${COMPRESS_RET})" >&2
fi

# Gzip
tar cvzf ${DIST_DIR}/${RELEASE_PACKAGE_NAME}.tar.gz ${PROJECT}'.'${WRAPPER_EXTENSION}

COMPRESS_RET=$?
if [ $COMPRESS_RET -ne 0 ]; then
    consoleLog "Gzip compression failed (${COMPRESS_RET})" >&2
fi

# Bzip2
tar cvjf ${DIST_DIR}/${RELEASE_PACKAGE_NAME}.tar.bz2 ${PROJECT}'.'${WRAPPER_EXTENSION}

COMPRESS_RET=$?
if [ $COMPRESS_RET -ne 0 ]; then
    consoleLog "Bzip2 compression failed (${COMPRESS_RET})" >&2
fi

echo
echo "Ready for release ${CURRENT_VERSION_STRING}"