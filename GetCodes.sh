#!/bin/bash
#Obtiene la hora anterior
fechahora=`date +'^%b %e %H.* status:' -d '-1 hour'`
#Ultimas 2 bitacoras de donde se obtendra la informacion
last2=`ls -1tr /var/log/path-apache2/error_log* | tail -2`
rm statustemp.txt
#Ciclo para los ultimos 2 archivos
for file in ${last2[@]}
do
   #Si es un archivo de tipo bzip2:
   if [[ `file --mime-type -b "$file"` == "application/x-bzip2" ]]
   then
      #Entonces busca con bzgrep
      bzgrep "$fechahora" $file | awk '{print $11}' >> statustemp.txt
   else
      #Si no es un bzip2 entonces busca con awk
      awk -v search="$fechahora" '$0 ~ search {print $11}' $file >> statustemp.txt
   fi
done
fechahoralog=`date +'%F_%H' -d '-1 hour'`
#De lo encontrado en los archivos se metio a el archivo statustemp.txt, del cual hacemos un conteo con uniq
#Ordenamos por la columna 2 y agregamos el delimitador "," sustituyendo los retornos de carro (Enters)
count=$(sort statustemp.txt | uniq -c | sort -k2 | sed 's/ status//;s/ //g' | awk -F ':' '{print $2":"$1}' | tr '\n' ',')
#Por ultimo ingresamos la fecha separada por un pipe y el conteo realizado en el archivo codestatus-*log del mes que corresponda
echo "$fechahoralog|$count" >> /var/log/reportes/codestatus-`date +'%Y%m' -d '-1 hour'`.log
