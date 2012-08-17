#! /bin/bash

cd `dirname $0`

# Import utilities from common.sh
. ./common.sh

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
sed -E -i '' -e 's!(# '${PROJECT}') [0-9a-z.]+!\1 '${NEW_VERSION_STRING}'!' $README_FILE

echo 'Version bumped to ' ${NEW_VERSION_STRING} '('${NEW_VERSION}')'
