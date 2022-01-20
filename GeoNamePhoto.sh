#!/bin/bash


# OutDir="/nfs/Public/FinishedPictures/"
OutDir=~/Pictures/

IFS=$'\n'
for i in $(find . -type f -iname "*.jpg") ; do
  echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"."$i"."XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  lat=$(exiftool -gpslatitude -n "$i" | tr -d 'GPS Latitude : ')
  lon=$(exiftool -gpslongitude -n "$i" | tr -d 'GPS Longitude : ')
  echo Lat:"$lat"
  echo Lon:"$lon"

  if [ "$lat" = "0.00000" ] ; then
    echo Zero Latitude
    exiftool -P -r '-FileName<'"$OutDir"'${FileModifyDate}(${Model;}).%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${CreateDate}(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}(${Model;}).%le' "$i"
    if [ -e "$i" ]  ; then
      exiftool -P -r '-FileName<#${FileModifyDate}.%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${CreateDate}.%le' '-FileName<'"$OutDir"'${DateTimeOriginal}.%le' "$i"
      echo No Camera Model
    fi
    echo "No Location 1"

  else

    if [ -z "$lat" -o -z "$lon" -o "$lat" = 0 ] ; then
      echo NULL Lon or Lat
      # 'DateTimeOriginal' not defined
      # 'CreateDate' not defined

      exiftool -P -r '-FileName<'"$OutDir"'${FileModifyDate}(${Model;}).%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${CreateDate}(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}(${Model;}).%le' "$i"
      if [ -e "$i" ]  ; then
       exiftool -P -r '-FileName<'"$OutDir"'${FileModifyDate}.%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${CreateDate}.%le' '-FileName<'"$OutDir"'${DateTimeOriginal}.%le' "$i"
       echo No Cam Model 3
      fi
      echo "No Location 2"
    else
      echo GOOD Lat/Lon
      MapLoc=$(curl -s --retry 10 "https://nominatim.openstreetmap.org/reverse?format=json&zoom=10&email=tduffin@gmail.com&accept-language=en-us&lat=$lat&lon=$lon&zoom=18&addressdetails=1")

      #
      # "address":{"state":"South Cyprus","country":"Cyprus","country_code":"cy"}
      # "address":{"state_district":"Greater London","state":"England","country":"United Kingdom","country_code":"gb"}
      # "address":{"city":"Bellevue","county":"King County","state":"Washington","country":"United States","country_code":"us"}
      # "address":{"municipality":"Council of the City of Sydney","state":"New South Wales","country":"Australia","country_code":"au"}
      # "address":{"municipality":"Waverley Council","state":"New South Wales","country":"Australia","country_code":"au"}
      # "address":{"municipality":"Torcy","county":"Seine-et-Marne","state":"Ile-de-France","region":"Metropolitan France","country":"France","country_code":"fr"}
      # "address":{"municipality":"Le Raincy","county":"Seine-Saint-Denis","state":"Ile-de-France","region":"Metropolitan France","country":"France","country_code":"fr"}
      #

      city=$(echo $MapLoc | jq '.address.city' | tr -d '"')
      echo "city " . "$city"
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.town' | tr -d '"')
          echo "town" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(echo $MapLoc | jq '.address.village' | tr -d '"')
          echo "village" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(echo $MapLoc | jq '.address.hamlet' | tr -d '"')
          echo "hamlet" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.historic' | tr -d '"')
          echo "historic" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(echo $MapLoc | jq '.address.neighbourhood' | tr -d '"')
          echo "neighbourhood" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(echo $MapLoc | jq '.address.suburb' | tr -d '"')
          echo "suburb" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(echo $MapLoc | jq '.address.municipality' | tr -d '"')
          echo "municipality" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(echo $MapLoc | jq '.address.state_district' | tr -d '"')
          echo "state_district" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(echo $MapLoc | jq '.address.county' | tr -d '"')
          echo "county" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city=$(echo $MapLoc | jq '.address.state' | tr -d '"')
          echo "state" . "$city"
      fi
      if [ "$city" = "null" ]; then
          city="Unknown"
          echo "MISSING city ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ " . $MapLoc
          echo $MapLoc > GeoNameCityError.txt
      fi

      country=$(echo $MapLoc | jq '.address.country' | tr -d '"')
      echo "$city"
      echo "$country"

      exiftool -P -r '-FileName<'"$OutDir"'${FileModifyDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${CreateDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}('"$city"')(${Model;}).%le' -d '%Y-%m/'"$country"'/%Y-%m-%d %Hh%Mm%Ss%%-c' "$i"
      if [ -e "$i" ] ; then
        exiftool -P -r '-FileName<'"$OutDir"'${FileModifyDate}('"$city"').%le' '-FileName<'"$OutDir"'${CreateDate}('"$city"').%le' '-FileName<'"$OutDir"'${DateTimeOriginal}('"$city"').%le' -d '%Y-%m/'"$country"'/%Y-%m-%d %Hh%Mm%Ss%%-c' "$i"
        echo No Camera Model 2
      fi
      echo Sleeping 2 seconds...
      sleep 2
    fi
  fi
  find . -type d -empty -delete
  find . -type d -empty -delete
  find . -type d -empty -delete
  find . -type d -empty -delete
done



