#!/bin/bash

# https://github.com/TippyTurtle/GeoNamePhotos/

# This script should rename (move) all jpgs, recursively, to something similar to ~/Pictures/2017-01/United States/2017-01-03 13h27m29s(Bellevue)(D6603).jpg

# Before running, I highly recommend running rdfind to remove duplicats. By default it won't remove duplicates, you need rdfind -deleteduplicates true 
# rdfind prioritizes the order the the paths you include, deleting the lowest priority, like rdfind -deleteduplicates true /Most/Important/Path /Less/Important /Least .
# rdfind looks for duplicates across all file types...not just jpg.

# You need to have the following installed:
# exiftool
# coreutils (for tr)
# curl
# jq

# OutDir="/nfs/Public/FinishedPictures/"
OutDir=~/Pictures/
email=YourEmail@Domain.ReplaceMe

IFS=$'\n'
for i in $(find . -type f -iname "*.jpg") ; do
  echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"."$i"."XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  lat=$(exiftool -gpslatitude -n "$i" | tr -d 'GPS Latitude : ')
  lon=$(exiftool -gpslongitude -n "$i" | tr -d 'GPS Longitude : ')
  exiftool -n -DateTimeOriginal "$i"
  echo Lat:"$lat"
  echo Lon:"$lon"

  if [ "$lat" = "0.00000" ] ; then
    echo Zero Latitude
    exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}(${Model;}).%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${CreateDate}(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}(${Model;}).%le' "$i"
    if [ -e "$i" ]  ; then
      exiftool -fixBase -v0 -P '-FileName<#${FileModifyDate}.%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${CreateDate}.%le' '-FileName<'"$OutDir"'${DateTimeOriginal}.%le' "$i"
      echo No Camera Model
    fi
    echo "No Location 1"

  else

    if [ -z "$lat" -o -z "$lon" -o "$lat" = 0 ] ; then
      echo NULL Lon or Lat
      # 'DateTimeOriginal' not defined
      # 'CreateDate' not defined

      exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}(${Model;}).%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${CreateDate}(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}(${Model;}).%le' "$i"
      if [ -e "$i" ]  ; then
       exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}.%le' -d '%Y-%m//%Y-%m-%d %Hh%Mm%Ss%%-c' '-FileName<'"$OutDir"'${CreateDate}.%le' '-FileName<'"$OutDir"'${DateTimeOriginal}.%le' "$i"
       echo No Cam Model 3
      fi
      echo "No Location 2"
    else
      echo GOOD Lat/Lon
      MapLoc=$(curl -s --retry 10 "https://nominatim.openstreetmap.org/reverse?format=json&zoom=10&email=$email&accept-language=en-us&lat=$lat&lon=$lon&zoom=19&addressdetails=1")
      echo "$MapLoc"

      city=$(echo $MapLoc | jq '.address.city' | tr -d '"')
      echo "city" . "$city"

      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.town' | tr -d '"')
          echo "town" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.village' | tr -d '"')
          echo "village" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.hamlet' | tr -d '"')
          echo "hamlet" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.suburb' | tr -d '"')
          echo "suburb" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.municipality' | tr -d '"')
          echo "municipality" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.state_district' | tr -d '"')
          echo "state_district" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.county' | tr -d '"')
          echo "county" . "$city"
      fi
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.state' | tr -d '"')
          echo "state" . "$city"
      fi

      # Fields more specific than City...but you sort of need city still to be clear
      if [ $(echo $MapLoc | jq '.address.neighbourhood' | tr -d '\"') != 'null' ]; then
          if [ "$city" = 'null' ]; then
              city="$(echo $MapLoc | jq '.address.neighbourhood' | tr -d '\"')"
              echo neighbourhood . "$city"
          else
              city="$(echo $MapLoc | jq '.address.neighbourhood' | tr -d '\"')-$city"
              echo neighbourhood . "$city"
          fi
      fi
      if [ $(echo $MapLoc | jq '.address.man_made' | tr -d '\"') != 'null' ]; then
          if [ "$city" = 'null' ]; then
              city="$(echo $MapLoc | jq '.address.man_made' | tr -d '\"')"
              echo man_made . "$city"
          else
              city="$(echo $MapLoc | jq '.address.man_made' | tr -d '\"')-$city"
              echo man_made . "$city"
          fi
      fi
      if [ $(echo $MapLoc | jq '.address.amenity' | tr -d '\"') != 'null' ]; then
          if [ "$city" = 'null' ]; then
              city="$(echo $MapLoc | jq '.address.amenity' | tr -d '\"')"
              echo amenity . "$city"
          else
              city="$(echo $MapLoc | jq '.address.amenity' | tr -d '\"')-$city"
              echo amenity . "$city"
          fi
      fi
      if [ $(echo $MapLoc | jq '.address.place' | tr -d '\"') != 'null' ]; then
          if [ "$city" = 'null' ]; then
              city="$(echo $MapLoc | jq '.address.place' | tr -d '\"')"
              echo place . "$city"
          else
              city="$(echo $MapLoc | jq '.address.place' | tr -d '\"')-$city"
              echo place . "$city"
          fi
      fi
      if [ $(echo $MapLoc | jq '.address.building' | tr -d '\"') != 'null' ]; then
          if [ "$city" = 'null' ]; then
              city="$(echo $MapLoc | jq '.address.building' | tr -d '\"')"
              echo building . "$city"
          else
              city="$(echo $MapLoc | jq '.address.building' | tr -d '\"')-$city"
              echo building . "$city"
          fi
      fi
      if [ $(echo $MapLoc | jq '.address.tourism' | tr -d '\"') != 'null' ]; then
          if [ "$city" = 'null' ]; then
              city="$(echo $MapLoc | jq '.address.tourism' | tr -d '\"')"
              echo tourism . "$city"
          else
              city="$(echo $MapLoc | jq '.address.tourism' | tr -d '\"')-$city"
              echo tourism . "$city"
          fi
      fi
      if [ $(echo $MapLoc | jq '.address.historic' | tr -d '\"') != 'null' ]; then
          if [ "$city" = 'null' ]; then
              city="$(echo $MapLoc | jq '.address.historic' | tr -d '\"')"
              echo historic . "$city"
          else
              city="$(echo $MapLoc | jq '.address.historic' | tr -d '\"')-$city"
              echo historic . "$city"
          fi
      fi
      if [ $(echo $MapLoc | jq '.address.office' | tr -d '\"') != 'null' ]; then
          if [ "$city" = 'null' ]; then
              city="$(echo $MapLoc | jq '.address.office' | tr -d '\"')"
              echo office . "$city"
          else
              city="$(echo $MapLoc | jq '.address.office' | tr -d '\"')-$city"
              echo office . "$city"
          fi
      fi

      # Last ditch effort to have some type of location in the filename.
      if [ "$city" = 'null' ]; then
          city=$(echo $MapLoc | jq '.address.country' | tr -d '"')
          echo "country" . "$city"
      fi


      # Very odd, it has geotags, but openstreetmap couldn't give me a name.
      if [ "$city" = 'null' ]; then
          echo "MISSING city ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ \n$city\n $MapLoc"
          city="Unknown"
          echo $MapLoc >> GeoNameCityError.txt
      fi

      country=$(echo $MapLoc | jq '.address.country' | tr -d '"')
      echo "$city"
      echo "$country"

      exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${CreateDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}('"$city"')(${Model;}).%le' -d '%Y-%m/'"$country"'/%Y-%m-%d %Hh%Mm%Ss%%-c' "$i"
      if [ -e "$i" ] ; then
        exiftool -fixBase -v0 -P '-FileName<'"$OutDir"'${FileModifyDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${CreateDate}('"$city"')(${Model;}).%le' '-FileName<'"$OutDir"'${DateTimeOriginal}('"$city"')(${Model;}).%le' -d '%Y-%m/'"$country"'/%Y-%m-%d %Hh%Mm%Ss%%-c' "$i"
        echo No Camera Model 2
      fi
      echo Sleeping 2 seconds...
      sleep 2
    fi
  fi
done

find . -type d -empty -delete
find . -type d -empty -delete
find . -type d -empty -delete
find . -type d -empty -delete
