#! /bin/bash

########################################################
# You should edit theses variables                     #

PROGRAM='MaxColumnsPlugin'
README_FILE='Readme.md'

# You shoud not have to edit the rest of the script    #
########################################################

cd `dirname $0`

PLIST_FILE=`find . -name "${PROGRAM}-Info.plist"`

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

CURRENT_VERSION_STRING=`extractPlistValueFromKey 'CFBundleShortVersionString' $PLIST_FILE`
CURRENT_VERSION=`extractPlistValueFromKey 'CFBundleVersion' $PLIST_FILE`

echo -n 'Current version number is : '

echo $CURRENT_VERSION_STRING '('${CURRENT_VERSION}')'

echo -n 'Enter new version number : '
read NEW_VERSION_STRING

NEW_VERSION=$((`extractPlistValueFromKey 'CFBundleVersion' ${PLIST_FILE}` + 1))

echo 'New version number will be :' ${NEW_VERSION_STRING} '('${NEW_VERSION}')'
echo -n 'Do you confirm [Yn] ? '
read CONFIRM_RES

if [ "$CONFIRM_RES" = "n" ]; then
    exit 1
fi

# Replace version in .plist
replacePlistValueFromKey 'CFBundleShortVersionString' $NEW_VERSION_STRING $PLIST_FILE
replacePlistValueFromKey 'CFBundleVersion' $NEW_VERSION $PLIST_FILE

# Replace version in Readme
sed -E -i '' -e 's!(# '${PROGRAM}') [0-9a-z.]+!\1 '${NEW_VERSION_STRING}'!' $README_FILE

echo 'Version bumped to ' ${NEW_VERSION_STRING} '('${NEW_VERSION}')'
