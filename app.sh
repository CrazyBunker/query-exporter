#!/bin/sh
_CONFIG_NEW="/etc/config.yaml.new"
cp /etc/exporter/config.yaml $_CONFIG_NEW
echo "databases:" >> $_CONFIG_NEW
for i in $(env | grep DSN_ ); do
   echo $i
   DBNAME=$(echo $i | sed -e "s/^DSN_//g" -e "s/=.*$//g")
   CONN=$(echo $i | sed "s/^DSN_.*=m/m/g")
   echo "  $DBNAME:" >> $_CONFIG_NEW
   echo "    dsn: \"$CONN\"" >> $_CONFIG_NEW
   echo "    autocommit: false" >> $_CONFIG_NEW
done
query-exporter $@

