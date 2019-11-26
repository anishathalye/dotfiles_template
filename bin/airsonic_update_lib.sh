#!/usr/bin/env sh
#
# inpsired from Paul Komurka https://github.com/pawlex/pub.scripts.misc
#
. $HOME/.env_private

COOKIE="cookie.curl"
STORECOOKIE="--cookie-jar $COOKIE"
LOADCOOKIE="-b $COOKIE"
URLROOT=$AIRSONIC_URL
ADMIN_USERNAME=$AIRSONIC_ADMIN_USER
ADMIN_PASSWORD=$AIRSONIC_ADMIN_PASS # who cares of this password anyway!GG^

# Pull the page to get the CSRF and store the initial cookie.
RETVAL=`curl -s ${STORECOOKIE} $URLROOT/login`
RETVAL=`echo $RETVAL | sed -n -e 's/^.*_csrf//p'`
CSRF=`echo $RETVAL | awk -F'"' '{print $3}'`
# Authenticate to the sonic server using previous cooking, storing the new cookie.
AUTH=`curl -s ${LOADCOOKIE} ${STORECOOKIE} --data "_csrf="$CSRF"&j_username="${ADMIN_USERNAME}"&j_password="${ADMIN_PASSWORD}"&remember-me=1" $URLROOT/login`
# Send the rescan command, using last stored cookie.
RESCAN=`curl -s ${LOADCOOKIE} ${STORECOOKIE} $URLROOT/musicFolderSettings.view?scanNow`
rm -f $COOKIE
if [ ${#RESCAN} -le 1 ]; then echo "error updating library" ; exit
else echo "Scanning library started"
fi
