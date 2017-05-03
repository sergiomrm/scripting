#!/bin/bash
fechahora=`date +'^%b %e %H.* status:' -d '-1 hour'`
last2=`ls -1tr /var/log/path-apache2/error_log* | tail -2`
rm statustemp.txt
for file in ${last2[@]}
do
   if [[ `file --mime-type -b "$file"` == "application/x-bzip2" ]]
   then
      bzgrep "$fechahora" $file | awk '{print $11}' >> statustemp.txt
   else
      awk -v search="$fechahora" '$0 ~ search {print $11}' $file >> statustemp.txt
   fi
done
fechahoralog=`date +'%F_%H' -d '-1 hour'`
count=$(sort statustemp.txt | uniq -c | sort -k2 | sed 's/ status//;s/ //g' | awk -F ':' '{print $2":"$1}' | tr '\n' ',')
echo "$fechahoralog|$count" >> /var/log/reportes/codestatus-`date +'%Y%m' -d '-1 hour'`.log
