#! /bin/sh

## Unbound Statistics

RAWFILE="/usr/local/unbound/log.d/unbound_stats"
TMPFILE="/usr/local/unbound/log.d/unbound_stats.tmp"
LOGFILE="/usr/local/unbound/log.d/unbound-stats.log"

# Run unbound-control and create file with statistics
/usr/local/unbound/unbound.d/sbin/unbound-control stats_noreset > ${RAWFILE}

# Remove unnecessary lines
sed -r '/.*(histogram|thread).*/d' ${RAWFILE} > ${TMPFILE}

# Multiline to single line, separated with commas
awk -vRS="" -vOFS=',' '$1=$1' ${TMPFILE} > ${LOGFILE}

## Healthcheck

PORT="5335" # Change to the port Unbound is listening on 127.0.0.1 (localhost)
DOMAIN="unbound.net" # The domain/host to query in the extended check
EXTENDED="0" # Change this to "1" if you would like to verify name resolution using drill

CHECK_PORT="$(netstat -ln | grep -c ":$PORT")" &> /dev/null

if [[ "$CHECK_PORT" -eq 0 ]]; then
  echo "⚠️ Port $PORT not open"
  exit 1
else
  echo "ℹ️ Port $PORT open"
  if [[ "$EXTENDED" = "0" ]]; then
    exit 0
  fi
fi

## Extended healthcheck

IP="$(drill -Q -p $PORT $DOMAIN @127.0.0.1)" &> /dev/null

if [[ $? -ne 0 ]]; then
  echo "⚠️ Domain '$DOMAIN' not resolved"
  exit 1 
else
  echo "ℹ️ Domain '$DOMAIN' resolved to '$IP'"
  exit 0
fi

