# GeoNamePhotos
  
  First ham handed attempt to post this. Nasty bunch of hard-coded paths and no error checking. Gulp.
  
  This bash script should run through all the subdirectories from where you run it looking for jpg files and renameing (moving) them to something similar to:

  ~/Pictures/2017-01/United States/2017-01-03 13h27m29s(Bellevue)(D6603).jpg
  
  **This is:**
  ~/Pictures/
  photo creation \<year\>\<month\>
  ...if there are geo tags...
  /\<country\>/
  ...with a file name of...
  photo creation \<year\>-\<month\>-\<day\> \<hour\>h-\<minute\>m-\<second\>s(\<city\>)(\<camera model\>).jpg
  
  **You need to have the following installed:**
  - exiftool
  - coreutils (for tr)
  - curl
  - jq
  
  
  By grouping by Country, I have found the paths sort of seperate different vacations...and by having the "city" in the jpg title after the date/time, you can easily see the different stops you made during you trip.
  
