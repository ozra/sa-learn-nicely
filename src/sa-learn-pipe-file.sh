#!/bin/bash

mkdir -p /var/tmp/sa-learn-pipeline/
log_filename=/var/tmp/sa-learn-pipeline.log

echo "$$: start writing piped ($*) to file" >> $log_filename

cat<&0 >> /var/tmp/sa-learn-pipeline/sendmail${*}--msg-$$.txt

echo "$$: done writing" >> $log_filename 

exit 0

