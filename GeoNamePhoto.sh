#!/bin/bash

# https://github.com/TippyTurtle/GeoNamePhotos/

# This script should rename (move) all jpgs, recursively, to something similar to ~/Pictures/2017-01/United States/2017-01-03 13h27m29s(Bellevue)(D6603).jpg

# Before running, I highly recommend running rdfind to remove duplicats. By default it won't remove duplicates, you need rdfind -deleteduplicates true 
# rdfind prioritizes the order the the paths you include, deleting the lowest priority, like rdfind -deleteduplicates true /Most/Important/Path /Less/Important /Least .
# rdfind looks for duplicates across all file types...not just jpg.

# You need to have the following installed:
# exiftool
# curl
# jq

# OutDir="/nfs/Public/FinishedPictures/"
OutDir=~/Pictures/
email=YourEmail@Domain.ReplaceMe

IFS=$'\n'
# for i in $(find . -type f \( -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.mov" -o -iname "*.mp4" -o -iname "*.wmv" -o -iname "*.avi" -o -iname "*.3gp" \)) ; do
for i in $(find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.cr2" \)) ; do

    echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"."$i"."XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    lat=$(exiftool -GPSLatitude -j -n "$i" |  jq -r '.[0].GPSLatitude')
    lon=$(exiftool -GPSLongitude -j -n "$i" |  jq -r '.[0].GPSLongitude')

    exiftool -n -DateTimeOriginal "$i"
    echo "lat=$lat&lon=$lon"

    if [ -z "$lat" -o "$lat" = 0 -o "$lat" = 'null' ] ; then
      echo NULL Lon or Lat

      exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}(${Model;}).%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${ModifyDate}(${Model;}).%le' '-FileName<'"$OutDir"'${ProfileDateTime}(${Model;}).%le' '-FileName<'"$OutDir"'${CreateDate}(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}(${Model;}).%le' "$i"
      if [ -e "$i" ]  ; then
       exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}.%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${ModifyDate}.%le' '-FileName<'"$OutDir"'${ProfileDateTime}.%le' '-FileName<'"$OutDir"'${CreateDate}.%le' '-FileName<'"$OutDir"'${DateTimeOriginal}.%le' "$i"
       echo No Cam Model 3
      fi
      echo "No Location 2"
    else
      echo GOOD Lat/Lon
      MapLoc=$(curl -s --retry 10 "https://nominatim.openstreetmap.org/reverse?format=json&zoom=10&email=$email&accept-language=en-US,en;q=0.5&lat=$lat&lon=$lon&zoom=19&addressdetails=1")
      echo "$MapLoc"

      city=$(echo $MapLoc |  jq -r '.address.city')
      echo "city" . "$city"

      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.town')
          echo "town" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.village')
          echo "village" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.hamlet')
          echo "hamlet" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.suburb')
          echo "suburb" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.municipality')
          echo "municipality" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.state_district')
          echo "state_district" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.county')
          echo "county" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.state')
          echo "state" . "$city"
      fi
      Landmark='null'

      # Find nearest Landmark. It gets overwritten with more and more specific place names, if they exist.
      if [ $(echo $MapLoc |  jq -r '.address.suburb') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.suburb')"
          echo suburb . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.quarter') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.quarter')"
          echo quarter . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.road') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.road')"
          echo road . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.neighbourhood') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.neighbourhood')"
          echo neighbourhood . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.place') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.place')"
          echo place . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.building') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.building')"
          echo building . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.office') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.office')"
          echo office . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.man_made') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.man_made')"
          echo man_made . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.amenity') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.amenity')"
          echo amenity . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.historic') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.historic')"
          echo historic . "$Landmark"
      fi
      if [ $(echo $MapLoc |  jq -r '.address.tourism') != 'null' ]; then
          Landmark="$(echo $MapLoc |  jq -r '.address.tourism')"
          echo tourism . "$Landmark"
      fi

      # Add the nearist landmark to the city name
      if [ "$city" = 'null' ]; then
          city="$Landmark"
      else
          if [ "$Landmark" = 'null' ]; then
              city="$city"
          else
              city="$Landmark-$city"
          fi
      fi

      # Last ditch effort to have some type of location in the filename.
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc |  jq -r '.address.country')
          echo "country" . "$city"
      fi


      # Very odd, it has geotags, but openstreetmap couldn't give me a name.
      if [ "$city" = 'null' ]; then
          echo "MISSING city ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ \n$city\n $MapLoc"
          city="Unknown"
          echo $MapLoc >> GeoNameCityError.txt
      fi

      country=$(echo $MapLoc |  jq -r '.address.country')
      echo 
      echo "City is $city in the country $country"

      exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${ModifyDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${ProfileDateTime}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${CreateDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}('"$city"')(${Model;}).%le' -d '%Y-%m/'"$country"'/%Y-%m-%d %Hh%Mm%Ss%%-c' "$i"
      if [ -e "$i" ] ; then
        exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}('"$city"').%le' '-FileName<'"$OutDir"'${ModifyDate}('"$city"').%le' '-FileName<'"$OutDir"'${ProfileDateTime}('"$city"').%le' '-FileName<'"$OutDir"'${CreateDate}('"$city"').%le' '-FileName<'"$OutDir"'${DateTimeOriginal}('"$city"').%le' -d '%Y-%m/'"$country"'/%Y-%m-%d %Hh%Mm%Ss%%-c' "$i"
        echo No Camera Model 2
      fi
      # Do not remove this. It would be evil to OpenStreetMaps and against their terms of use.  Consider making it much longer and running overnight.
      echo Sleeping 2 seconds...
      sleep 20
    fi
done

find . -type d -empty -delete
find . -type d -empty -delete
find . -type d -empty -delete
find . -type d -empty -delete
