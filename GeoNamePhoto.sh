#!/bin/bash

# https://github.com/TippyTurtle/GeoNamePhotos/

# This script should rename (move) all images or vidoe files, recursively, to rename them something similar to: ~/Pictures/2013-12/United States/2013-12-17 13h27m02s(Silverwood Theme Park-Athol)(p500).jpg

# Before running, I highly recommend running rdfind to remove duplicats. By default it won't remove duplicates, you need rdfind -deleteduplicates true 
# rdfind prioritizes the order the the paths you include, deleting the lowest priority, like rdfind -deleteduplicates true /Most/Important/Path /Less/Important /Least .
# rdfind looks for duplicates across all file types...not just jpg.

# You need to have the following installed:
# exiftool
# curl
# jq

# OutDir='/nfs/Public/FinishedPictures/'
OutDir='~/Pictures/'
email=YourEmail@Domain.ReplaceMe

# FilesCollection=$(find . -type f \( -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.mov' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.avi' -o -iname '*.3gp' \))
FilesCollection=$(find . -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.cr2' \))
FileTotal=$(echo "$FilesCollection" | wc -l)
FileCount=0
StartTime=$(date +%s)

# Text Colors
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NORM=$(tput sgr0)

IFS=$'\n'
for CurrentFile in $FilesCollection ; do
  echo -e "${BOLD}$CurrentFile${NORM}"
  
  ExifData=$(exiftool -m -j -n $CurrentFile)
  # echo $ExifData

  lat=$(echo $ExifData | jq -r '.[0].GPSLatitude')
  lon=$(echo $ExifData | jq -r '.[0].GPSLongitude')

  if [ $(echo $ExifData | jq -r '.[0].Model') != 'null' ]; then
    CameraModel="($(echo $ExifData | jq -r '.[0].Model'))"
  else
    CameraModel=''
  fi

  CreateDateName='null'
  if [ $(echo $ExifData | jq -r '.[0].ModifyDate') != 'null' ] && [ $(echo $ExifData | jq -r '.[0].ModifyDate') != '0000:00:00 00:00:00' ]; then
    CreateDateName='ModifyDate'
  fi
  if [ $(echo $ExifData | jq -r '.[0].FileModifyDate') != 'null' ] && [ $(echo $ExifData | jq -r '.[0].FileModifyDate') != '0000:00:00 00:00:00' ]; then
    CreateDateName='FileModifyDate'
  fi
  if [ $(echo $ExifData | jq -r '.[0].ProfileDateTime') != 'null' ] && [ $(echo $ExifData | jq -r '.[0].ProfileDateTime') != '0000:00:00 00:00:00' ]; then
    CreateDateName='ProfileDateTime'
  fi
  if [ $(echo $ExifData | jq -r '.[0].CreateDate') != 'null' ] && [ $(echo $ExifData | jq -r '.[0].CreateDate') != '0000:00:00 00:00:00' ]; then
    CreateDateName='CreateDate'
  fi
  if [ $(echo $ExifData | jq -r '.[0].DateTimeOriginal') != 'null' ] && [ $(echo $ExifData | jq -r '.[0].DateTimeOriginal') != '0000:00:00 00:00:00' ]; then
    CreateDateName='DateTimeOriginal'
  fi
  if [ "$CreateDateName" == 'null' ]; then
    echo "NO DATA $ExifData"
    echo $(date) " No Date for image $ExifData" >> GeoNameCityError.txt
    exit 666
  fi

  if [ -z "$lat" -o "$lat" == 0 -o "$lat" == 'null' ] ; then
    city=''
    Country=''
  else
    # Do not remove this. It would be evil to OpenStreetMaps and against their terms of use if you hit them more than once every 1.5 seconds.
    # Consider making it much longer and running overnight if you have a ton of photo's.
    echo Sleeping 2 seconds...
    sleep 2

    MapLoc=$(curl -s --retry 10 "https://nominatim.openstreetmap.org/reverse?format=json&zoom=10&email=$email&accept-language=en-US,en;q=0.5&lat=$lat&lon=$lon&zoom=19&addressdetails=1")
    echo "lon=$lon&lat=$lat"
    echo "$MapLoc" | jq -r '.address' | fgrep -A 1 '{' | fgrep -A 1 '{' | fgrep -v '{' >> FirstAddressField.txt
    # echo "$MapLoc"

    # https://wiki.openstreetmap.org/wiki/User:Innesw/TagTree

    # Find a good "City"...first ones take priority over later ones
    city=$(echo $MapLoc |  jq -r '.address.city')

    if [ "$city" == 'null' ]; then
        city=$(echo $MapLoc |  jq -r '.address.town')
    fi
    if [ "$city" == 'null' ]; then
        city=$(echo $MapLoc |  jq -r '.address.village')
    fi
    if [ "$city" == 'null' ]; then
        city=$(echo $MapLoc |  jq -r '.address.hamlet')
    fi
    if [ "$city" == 'null' ]; then
        city=$(echo $MapLoc |  jq -r '.address.locality')
    fi
    if [ "$city" == 'null' ]; then
        city=$(echo $MapLoc |  jq -r '.address.municipality')
    fi
    if [ "$city" == 'null' ]; then
        city=$(echo $MapLoc |  jq -r '.address.state_district')
    fi
    if [ "$city" == 'null' ]; then
        city=$(echo $MapLoc |  jq -r '.address.county')
    fi
    if [ "$city" == 'null' ]; then
        city=$(echo $MapLoc |  jq -r '.address.state')
    fi

    # Find a good Landmark...first ones take priority over later ones
    Landmark=$(echo $MapLoc |  jq -r '.address.tourism')
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.historic')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.accommodation')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.cemetery')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.shop')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.natural')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.man_made')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.leisure')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.amenity')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.military')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.government')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.healthcare')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.office')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.building')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.place')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.waterway')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.railway')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.aeroway')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.neighbourhood')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.quarter')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.suburb')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.road')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.highway')
    fi

    # Add the nearist landmark to the city name
    if [ "$city" == 'null' ]; then
        if [ "$Landmark" == 'null' ]; then
            city=''
            echo $(date) " No City or Landmark lat=$lat&lon=$lon $MapLoc" >> GeoNameCityError.txt
        else
            city="$Landmark"
        fi
    else
        if [ "$Landmark" == 'null' ]; then
            city="($city)"
            echo $(date) " City but no Landmark lat=$lat&lon=$lon $MapLoc" >> GeoNameCityError.txt
        else
            city="($Landmark-$city)"
        fi
    fi

    if [ $(echo $MapLoc |  jq -r '.address.country')!='null' ]; then
      Country="$(echo $MapLoc |  jq -r '.address.country')/"
    else
      Country=''
    fi

  fi

  echo ---
  ExifToolCommand="FileName<$OutDir\${$CreateDateName}$city$CameraModel.%le"
  exiftool -m -fixBase -v0 -P -d '%Y-%m/'"$Country"'%Y-%m-%d %Hh%Mm%Ss%%-c' '-'"$ExifToolCommand"'' "$CurrentFile"
  echo ---

  (( FileCount=$FileCount+1 ))
  PercentDone=$(echo "scale=4; $FileCount*100/$FileTotal" | bc -l )
  RunTime=$( echo "$(date +%s) - $StartTime" | bc -l )
  SecondsLeft=$( echo "($RunTime/($PercentDone/100))-$RunTime;scale=0" | bc -l )
  SecondsLeft=${SecondsLeft%.*}
  echo 
  echo "$FileCount of $FileTotal. $PercentDone% complete."
  echo "Running for $RunTime seconds or $(( $RunTime / 60 )) minutes or $(( $RunTime / 60 / 60 )) hours."
  echo -e "${BLUE}$SecondsLeft seconds or $(( $SecondsLeft / 60 )) minutes or $(( $SecondsLeft / 60 / 60 )) hours left.${NC}"
  echo 
done

# Delete now empty folders
find . -type d -empty -delete
date
