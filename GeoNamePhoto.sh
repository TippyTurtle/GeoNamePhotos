#!/bin/bash

# https://github.com/TippyTurtle/GeoNamePhotos/

# This script should rename (move) all images or vidoe files, recursively, to rename them something similar to: ~/Pictures/2013-12/United States/2013-12-17 13h27m02s(Silverwood Theme Park-Athol)(p500).jpg

# Before running, I highly recommend running rdfind to remove duplicats. By default it won't remove duplicates, you need rdfind -deleteduplicates true 
# rdfind prioritizes the order the the paths you include, deleting the lowest priority, like rdfind -deleteduplicates true /Most/Important/Path /Less/Important /Least .
# rdfind looks for duplicates across all file types...not just jpg.


email='You@YourPlace.HOUSE'

# Text Colors
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NORM=$(tput sgr0)

# Initialize IsError variable
IsError=0

# You need to have the following installed:
# exiftool curl jq

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
    echo "exiftool is not installed. On Debian, run:"
    echo "sudo apt install libimage-exiftool-perl"
    IsError=1
fi

# Check if curl is installed 
if ! command -v curl &> /dev/null; then
    echo "curl is not installed. On Debian, run:"
    echo "sudo apt install curl"
    IsError=1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. On Debian, run:"
    echo "sudo apt install jq"
    IsError=1
fi

# Check if both arguments are present
if [ "$#" -lt 2 ]; then
    echo "Usage: GeoNamePhoto.sh /source/directory/ /output/directory/"
    IsError=1
fi

# Assign the arguments to variables
InDir="$1"
OutDir="$2"
FileTypes="$3"
GeoNamePhotoErrors=$InDir\GeoNameCityError.txt

# Check if directories exist
if [ ! -d "$InDir" ]; then
    echo "Error: $InDir does not exist."
    IsError=1
fi
if [ ! -d "$OutDir" ]; then
    echo "Error: $OutDir does not exist."
    IsError=1
fi

if [ -z "$FileTypes" ]; then
  echo "Photo's [p], Movie's [m] or Both [b]?"
  read -n1 choice
  echo
fi

case $FileTypes in
  p)
    FilesCollection=$(find $InDir -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.cr2' \))
    ;;
  m)
    FilesCollection=$(find $InDir -type f \( -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.mov' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.avi' -o -iname '*.3gp' \))
    ;;
  b)
    FilesCollection=$(find $InDir -type f \( -iname '*.mpg' -o -iname '*.mpeg' -o -iname '*.mov' -o -iname '*.mp4' -o -iname '*.wmv' -o -iname '*.avi' -o -iname '*.3gp' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.cr2' \))
    ;;
  *)
    echo "Invalid choice for file types."
    IsError=1
esac

# Exit with non-zero status code if any tool is missing
if [ "$IsError" -eq 1 ]; then
    exit 1
fi


FileTotal=$(echo "$FilesCollection" | wc -l)
FileCount=0
StartTime=$(date +%s)

echo "File count: $FileTotal"

#Use this log to find $Landmark fields that should have been used. You will need to process the list more with a "Group-By" tool to be more efficient.
echo $(date) > FirstAddressField.txt

#Most are false-positives, some sometimes you will find a legitmate field that should be used for or $city that was missed.
echo $(date) > "$GeoNamePhotoErrors"

IFS=$'\n'

for CurrentFile in $FilesCollection ; do
  echo -e "--------------------${BOLD}$CurrentFile${NORM}--------------------"
  
  ExifData=$(exiftool -fast2 -m -j -d '%Y-%m-%d %H:%M:%S' -c '%+1.14g' $CurrentFile)
  # echo $ExifData

  lat=$(echo $ExifData | jq -r '.[0].GPSLatitude' | sed 's/+//')
  lon=$(echo $ExifData | jq -r '.[0].GPSLongitude' | sed 's/+//')
  # echo "lat=$lat&lon=$lon"

  #Camera Model has be surprisingly useful to know who took the photo, particularly to know when you didn't, but were given a dump from someone else.
  CameraModel=''
  CameraModel=$(echo $ExifData | jq -r '.[0].Model')
  if [ "$CameraModel" != '' ] && [ "$CameraModel" != 'null' ]; then
    CameraModel="($(echo $ExifData | jq -r '.[0].Model'))"
  else
    CameraModel=''
    echo $(date) " No Camera $(echo $ExifData | sed 's/\n/-/g')" >> "$GeoNamePhotoErrors"
  fi
  
  # Bad date...zero: '1970-01-01 16:23:53' There is a lot of variation on the hour/minutes/seconds part, I just check year-month-day
  # FileModifyDate is sometimes is newer than all other dates including ModifyDate
  # Do not use ProfileDateTime, it is the date a camera profile was set, not when the photo was taken.
  # Maybe used MediaCreateDate and MediaModifyDate from mp4 files

  CreateDateName='null'
  PhotoTakeAt=''
  PhotoTakeAt=$(date)
  TempString=$(echo $ExifData | jq -r '.[0].FileModifyDate')
  if [ "$TempString" != 'null' ] && [ "$TempString" != '' ] &&  [ "$TempString" != '0000:00:00 00:00:00' ] && [ "$(date -d $TempString +'%Y-%m-%d')" != '1970-01-01' ]; then
    CreateDateName='FileModifyDate'
    PhotoTakeAt=$(date -d $TempString +'%Y-%m-%d %H:%M:%S')
  fi
  TempString="$(echo $ExifData | jq -r '.[0].ModifyDate')"
  if [ "$TempString" != 'null' ] && [ "$TempString" != '' ] &&  [ "$TempString" != '0000:00:00 00:00:00' ] && [ "$(date -d $TempString +'%Y-%m-%d')" != '1970-01-01' ]; then
    CreateDateName='ModifyDate'
    PhotoTakeAt=$(date -d $TempString +'%Y-%m-%d %H:%M:%S')
  fi
  TempString="$(echo $ExifData | jq -r '.[0].CreateDate')"
  if [ "$TempString" != 'null' ] && [ "$TempString" != '' ] &&  [ "$TempString" != '0000:00:00 00:00:00' ] && [ "$(date -d $TempString +'%Y-%m-%d')" != '1970-01-01' ]; then
    CreateDateName='CreateDate'
    PhotoTakeAt=$(date -d $TempString +'%Y-%m-%d %H:%M:%S')
  fi
  TempString="$(echo $ExifData | jq -r '.[0].DateTimeOriginal')"
  if [ "$TempString" != 'null' ] && [ "$TempString" != '' ] &&  [ "$TempString" != '0000:00:00 00:00:00' ] && [ "$(date -d $TempString +'%Y-%m-%d')" != '1970-01-01' ]; then
    CreateDateName='DateTimeOriginal'
    PhotoTakeAt=$(date -d $TempString +'%Y-%m-%d %H:%M:%S')
  fi
  if [ "$CreateDateName" == 'null' ]; then
    echo "NO DATA $ExifData"
    echo $(date) " No Date for image $(echo $ExifData | sed 's/\n/-/g')" >> "$GeoNamePhotoErrors"
    exit 666
  fi

  if [ -z "$lat" -o "$lat" == '+0.00000000000000' -o "$lat" == 'null' ] ; then
    city=''
    Country=''
    ImageDescription=$(date -d $PhotoTakeAt +'%A %d %B %Y at %I:%M:%S %p')
  else

    # Do not remove this. It would be evil to OpenStreetMaps and against their terms of use if you hit them more than once every 1.5 seconds.
    # Consider making it much longer and running overnight if you have a ton of photo's.
    echo Sleeping 3 seconds...
    sleep 3

    MapLoc=$(curl -s --retry 10 "https://nominatim.openstreetmap.org/reverse?format=json&zoom=10&email=$email&accept-language=en-US,en;q=0.5&lat=$lat&lon=$lon&zoom=19&addressdetails=1")

    # echo "$MapLoc" | jq -r '.address' | fgrep -A 1 '{' | fgrep -A 1 '{' | fgrep -v '{' >> FirstAddressField.txt
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
    # Ignoring: aerialway, craft
    Landmark=$(echo $MapLoc |  jq -r '.address.tourism')
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.historic')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.isolated_dwelling')
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
        Landmark=$(echo $MapLoc |  jq -r '.address.club')
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
        Landmark=$(echo $MapLoc |  jq -r '.address.display_name')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.emergency')
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
        Landmark=$(echo $MapLoc |  jq -r '.address.city_block')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.city_district')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.quarter')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.suburb')
    fi
    if [ "$Landmark" == 'null' ]; then
        Landmark=$(echo $MapLoc |  jq -r '.address.junction')
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
            echo $(date) " No City or Landmark $CurrentFile lat=$lat&lon=$lon $MapLoc" >> "$GeoNamePhotoErrors"
        else
            city="$Landmark"
        fi
    else
        if [ "$Landmark" == 'null' ]; then
            city="$city"
            echo $(date) " City but no Landmark $CurrentFile lat=$lat&lon=$lon $MapLoc" >> "$GeoNamePhotoErrors"
        else
            city="$Landmark-$city"
        fi
    fi

    if [ $(echo $MapLoc |  jq -r '.address.country')!='null' ]; then
      Country="$(echo $MapLoc |  jq -r '.address.country')"
      ImageDescription="$(echo $city | sed 's/-/, /') ($(echo $MapLoc |  jq -r '.address.country')) on $(date -d $PhotoTakeAt +'%A %d %B %Y at %I:%M:%S %p')"
    else
      Country=''
      ImageDescription="$(echo $city | sed 's/-/, /') on $(date -d $PhotoTakeAt +'%A %d %B %Y at %I:%M:%S %p')"
      echo $(date) " No Country lat=$lat&lon=$lon $MapLoc" >> "$GeoNamePhotoErrors"
    fi
    city="($city)"
  fi
# replace bad filename characters: \ / : " *   didn't   ? < > | % # $ & { } [ ]
  Country="$(echo $Country | sed 's/\//-/g;s/\\/-/g;s/\:/./g;s/\"//g;s/\*//g')/"
  city=$(echo $city | sed 's/\//-/g;s/\\/-/g;s/\:/./g;s/\"//g;s/\*//g')
  CameraModel=$(echo $CameraModel | sed 's/\//-/g;s/\\/-/g;s/\:/./g;s/\"//g;s/\*//g')

  echo -e "-------------------------------${BOLD}$ImageDescription${NORM}-------------------------------"
  # Add "-o ." to copy instead of move the files.  
  # Change -FileName to -TestName for a dry run with moving/copying files.
  # exiftool -m -fixBase -q -P -ImageDescription=''"$ImageDescription"'' -d '%Y-%m/'"$Country%"'Y-%m-%d %H.%M.%S%%-c' '-FileName<'"$OutDir\${$CreateDateName}$city$CameraModel.%le"'' ''"$CurrentFile"''
  exiftool -m -fixBase -q -P -d '%Y-%m/'"$Country%"'Y-%m-%d %H.%M.%S%%-c' '-FileName<'"$OutDir\${$CreateDateName}$city$CameraModel.%le"'' ''"$CurrentFile"''

    # Someone can do a better job at this, I can't deal with float in bash to save my life
  (( FileCount=$FileCount+1 ))
  PercentDone=$(echo "scale=4; $FileCount*100/$FileTotal" | bc -l )
  RunTime=$( echo "$(date +%s) - $StartTime" | bc -l )
  SecondsLeft=$( echo "($RunTime/($PercentDone/100))-$RunTime;scale=0" | bc -l )
  (( SecondsLeft=$SecondsLeft+1 ))
  SecondsLeft=${SecondsLeft%.*}
  
  echo 
  echo "$FileCount of $FileTotal. $(printf "%.2f" "$PercentDone")% complete."
  printf "Running for %02d:%02d:%02d.\n" $(($RunTime/3600)) $(($RunTime%3600/60)) $(($RunTime%60))
  printf "${BLUE}Only %02d:%02d:%02d left to go.${NC}\n" $(($SecondsLeft/3600)) $(($SecondsLeft%3600/60)) $(($SecondsLeft%60))
  echo 
done

# Delete now empty folders
find $InDir -type d -empty -delete -print
date
