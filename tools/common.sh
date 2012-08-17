################################################################################
#                                                                              #
#             This script should not be started direclty                       #
# It is a collection of function and utilities to be included in other scripts #
#                                                                              #
################################################################################

################################################################################
# You should edit theses variables                                             #

PROJECT='MaxColumnsPlugin'
WRAPPER_EXTENSION='mailbundle'
README_FILE='Readme.md'

# You shoud not have to edit the rest of the script                            #
################################################################################

# Return to the project root directory
PROJECT_HOME='..'
cd $PROJECT_HOME

# Log to stdout with date and time
consoleLog()
{
    echo '['$(date +'%a %Y-%m-%d %H:%M:%S %z')']' $@
}

# Generate a regular exp. to match a value from a .plist file based on a specified key
genPlistValueMatchRe() {
    local KEY=$1
    echo '(.*<key>'${KEY}'</key>[^<]*<string>)([^<]+)(</string>.*)'
}

# Extracts a value from a .plist file
extractPlistValueFromKey() {
    local KEY=$1
    local PLIST=$2
    sed -E -e ':a' -e 'N' -e '$!ba' -e "s!`genPlistValueMatchRe ${KEY}`!\2!g" ${PLIST}
}

# Replace a value from a .plist file
# /!\ Modify the .plist file in-place without warning /!\
replacePlistValueFromKey() {
    local KEY=$1
    local VALUE=$2
    local PLIST=$3
    sed -E -i '' -e ':a' -e 'N' -e '$!ba' -e "s!`genPlistValueMatchRe ${KEY}`!\1${VALUE}\3!g" ${PLIST}
}

# Defines some useful variables
PLIST_FILE=`find . -name "${PROJECT}-Info.plist"`
PBXPROJ_FILE=`find . -name "project.pbxproj"`

CURRENT_VERSION_STRING=`extractPlistValueFromKey 'CFBundleShortVersionString' $PLIST_FILE`
CURRENT_VERSION=`extractPlistValueFromKey 'CFBundleVersion' $PLIST_FILE`

SOURCES_DIR=${PWD}'/'${PROJECT}'/'
DIST_DIR=${SOURCES_DIR}'dist/'
BUILD_DIR_ROOT=${SOURCES_DIR}'build/'
BUILD_DIR_DEBUG=${BUILD_DIR_ROOT}'Debug/'
BUILD_DIR_RELEASE=${BUILD_DIR_ROOT}'Release/'
