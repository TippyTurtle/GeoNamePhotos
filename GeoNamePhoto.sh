#!/bin/bash

for i in *.jpg; do
  echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"."$i"."XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  lat=$(exiftool -gpslatitude -n "$i" | tr -d 'GPS Latitude : ')
  lon=$(exiftool -gpslongitude -n "$i" | tr -d 'GPS Longitude : ')
  echo Lat:"$lat"
  echo Lon:"$lon"

  if [ "$lat" = "0.00000" ] ; then
    echo Zero Value
    exiftool -P -r '-FileName</nfs/Public/FinishedPictures/${FileModifyDate}(${Make;} ${Model;}).%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName</nfs/Public/FinishedPictures/${CreateDate}(${Make;} ${Model;}).%le' '-FileName</nfs/Public/FinishedPictures/${DateTimeOriginal}(${Make;} ${Model;}).%le' "$i"
    if [ -e "$i" ]  ; then 
      exiftool -P -r '-FileName</nfs/Public/FinishedPictures/${FileModifyDate}.%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName</nfs/Public/FinishedPictures/${CreateDate}.%le' '-FileName</nfs/Public/FinishedPictures/${DateTimeOriginal}.%le' "$i"
      echo No Camera Model
    fi
    echo "No Location 1"

  else
    echo Not Zero Value

    if [ -z "$lat" -o -z "$lon" -o "$lat" = 0 ] ; then
      echo Empty Lon or Lat
  
      exiftool -P -r '-FileName</nfs/Public/FinishedPictures/${FileModifyDate}(${Make;} ${Model;}).%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName</nfs/Public/FinishedPictures/${CreateDate}(${Make;} ${Model;}).%le' '-FileName</nfs/Public/FinishedPictures/${DateTimeOriginal}(${Make;} ${Model;}).%le' "$i"
      if [ -e "$i" ]  ; then
       exiftool -P -r '-FileName</nfs/Public/FinishedPictures/${FileModifyDate}.%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName</nfs/Public/FinishedPictures/${CreateDate}.%le' '-FileName</nfs/Public/FinishedPictures/${DateTimeOriginal}.%le' "$i"
       echo No Cam Model 3
      fi
      echo "No Location 2"
    else
      city=$(curl --retry 10 "http://nominatim.openstreetmap.org/reverse?format=json&zoom=10&email=ZZZZ at ZZZZ.com&accept-language=en-us&lat=$lat&lon=$lon" | jq '.address.city' | tr -d '"')
      echo "city " . "$city"
      if [ "$city" = 'null' ]; then
          city=$(curl --retry 10 "http://nominatim.openstreetmap.org/reverse?format=json&zoom=10&accept-language=en-us&lat=$lat&lon=$lon" | jq '.address.town' | tr -d '"')
          echo "town" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(curl --retry 10 "http://nominatim.openstreetmap.org/reverse?format=json&zoom=10&accept-language=en-us&lat=$lat&lon=$lon" | jq '.address.village' | tr -d '"')
          echo "village" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(curl --retry 10 "http://nominatim.openstreetmap.org/reverse?format=json&zoom=10&accept-language=en-us&lat=$lat&lon=$lon" | jq '.address.hamlet' | tr -d '"')
          echo "hamlet" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city="Unknown"
          echo "No City: " . "$city"
      fi

      country=$(curl --retry 10 "http://nominatim.openstreetmap.org/reverse?format=json&zoom=10&email=ZZZZ at ZZZZ.com&accept-language=en-us&lat=$lat&lon=$lon" | jq '.address.country' | tr -d '"')
      echo "$city"
      echo "$country"
       
      exiftool -P -r '-FileName</nfs/Public/FinishedPictures/${FileModifyDate}('"$city"')(${Make;} ${Model;}).%le' '-FileName</nfs/Public/FinishedPictures/${CreateDate}('"$city"')(${Make;} ${Model;}).%le' '-FileName</nfs/Public/FinishedPictures/${DateTimeOriginal}('"$city"')(${Make;} ${Model;}).%le' -d '%Y-%m/'"$country"'/%Y-%m-%d %Hh%Mm%Ss%%-c' "$i"
      if [ -e "$i" ] ; then
      	exiftool -P -r '-FileName</nfs/Public/FinishedPictures/${FileModifyDate}('"$city"').%le' '-FileName</nfs/Public/FinishedPictures/${CreateDate}('"$city"').%le' '-FileName</nfs/Public/FinishedPictures/${DateTimeOriginal}('"$city"').%le' -d '%Y-%m/'"$country"'/%Y-%m-%d %Hh%Mm%Ss%%-c' "$i"
        echo No Camera Model 2
      fi
      sleep 5
    fi
  fi
done

