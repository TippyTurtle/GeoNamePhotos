# GeoNamePhotos
  
  This script should rename (move) all images or vidoe files, recursively, to rename them something similar to:
  ~/Pictures/2017-01/United States/2017-01-03 13h27m29s(Bellevue)(D6603).jpg

  Before running, I highly recommend running rdfind to remove duplicats. By default it won't remove duplicates, you need rdfind -deleteduplicates true 
  rdfind prioritizes the order the the paths you include, deleting the lowest priority, like rdfind -deleteduplicates true /Most/Important/Path /Less/Important /Least .
  rdfind looks for duplicates across all file types...not just jpg.
  
  **This is:**
  ~/Pictures/
  photo creation \<year\>\<month\>
  ...if there are geo tags...
  /\<country\>/
  ...with a file name of...
  photo creation \<year\>-\<month\>-\<day\> \<hour\>h-\<minute\>m-\<second\>s(\<city\>)(\<camera model\>).jpg
  
  **You need to have the following installed:**
  - exiftool
  - curl
  - jq
  
  
  By grouping by Country, I have found the paths sort of seperate different vacations...and by having the "city" in the jpg title after the date/time, you can easily see the different stops you made during you trip.
  
