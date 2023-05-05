#! /bin/sh

## Unbound Statistics

RAWFILE="/var/tmp/unbound_stats"
TMPFILE="/var/tmp/unbound_stats.log"
FILE="/usr/local/unbound/log.d/unbound-stats.log"

# Run unbound-control and create file with statistics
/usr/local/unbound/unbound.d/sbin/unbound-control stats_noreset > ${RAWFILE}

# Remove unnecessary lines
sed -r '/.*(histogram|thread).*/d' ${RAWFILE} > ${TMPFILE}

# Multiline to single line, separated with commas
awk -vRS="" -vOFS=',' '$1=$1' ${TMPFILE} > ${FILE}

## Healthcheck

nslookup internic.net 127.0.0.1:53 > /dev/null
STATUS=$?
if [[ ${STATUS} -ne 0 ]]
then
    exit 1
fi
