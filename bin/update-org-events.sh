#!/bin/bash

# Export org-journal events to ICS file using an emacs script
emacs --batch --script ~/bin/export-org-journal-to-ics.el 

S3_DESTINATION="s3://ezmiller/calendar"
ICS_FILE="org-events.ics"

echo "Uploading ICS file to S3: ${S3_DESTINATION}"

aws s3 cp ./${ICS_FILE} ${S3_DESTINATION}/${ICS_FILE} --acl public-read --profile ethans-aws

echo "Cleaning up..."

rm ~/bin/${ICS_FILE}

echo "Done"

