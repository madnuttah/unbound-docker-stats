#! /bin/sh

## Unbound Statistics

RAWFILE="/usr/local/unbound/log.d/unbound_stats"
TMPFILE="/usr/local/unbound/log.d/unbound_stats.tmp"
FILE="/usr/local/unbound/log.d/unbound-stats.log"

# Run unbound-control and create file with statistics
/usr/local/unbound/unbound.d/sbin/unbound-control stats_noreset > ${RAWFILE}

# Remove unnecessary lines
sed -r '/.*(histogram|thread).*/d' ${RAWFILE} > ${TMPFILE}

# Multiline to single line, separated with commas
awk -vRS="" -vOFS=',' '$1=$1' ${TMPFILE} > ${FILE}

## Healthcheck

#! /bin/sh
netstat -ln | grep -c ":5335" &> /dev/null # Change ":5335" to the Unbound port you may use
STATUS=$?
if [[ ${STATUS} -lt 1 ]]
then
    exit 0
fi

