# GeoNamePhotos
  
  This script should rename (move) all images or video files, recursively, to rename them something similar to:
  ~/Pictures/2013-12/United States/2013-12-17 13h27m02s(Silverwood Theme Park-Athol)(p500).jpg
  
  This scripts gets place names from openstreetmap.org using GPS data in the photo.
  
  **You need to have the following installed:**
  - exiftool
  - curl
  - jq

Before running, I highly recommend running <A hRef="https://rdfind.pauldreik.se/" target="_blank">rdfind</A> to remove duplicates. By default rdfind won't remove duplicates, you need `rdfind -deleteduplicates true .` to actully (permenantly) delete dumplicates.

rdfind prioritizes the order the the paths you include, deleting the lowest priority, like `rdfind -deleteduplicates true /Most/Important/Path /Less/Important /Least .`

rdfind looks for duplicates across all file types...not just jpg.

  **Filename Output:**
```
  ~/Pictures/<year>-<month>/<year>-<month>-<day> <hour>h-<minute>m-<second>s(<nearest landmark>-<city>)(<camera model>).jpg
```
  **If there are no are geo tags then the Filename output is:**
```
  ~/Pictures/<year>-<month>/<year>-<month>-<day> <hour>h-<minute>m-<second>s(<camera model>).jpg
```

  **Example Full Output:**
```
~/Pictures/
├── 2015-07
│   ├── 2015-07-02 06.16.03(D6603).jpg
│   ├── 2015-07-22 12.33.50(D6603).jpg
│   ├── 2015-07-25 20.57.03(Canon EOS 1100D).jpg
│   ├── 2015-07-25 20.57.14(Canon EOS 1100D).jpg
│   ├── 2015-07-25 21.15.52-1(Canon EOS 1100D).jpg
│   ├── 2015-07-25 21.15.52(Canon EOS 1100D).jpg
│   ├── 2015-07-25 21.19.54-1(Canon EOS 1100D).jpg
│   ├── 2015-07-25 21.19.54(Canon EOS 1100D).jpg
│   ├── 2015-07-25 21.28.32(Canon EOS 1100D).jpg
│   ├── Bosnia and Herzegovina
│   │   ├── 2015-07-06 11.19.34(Međugorje Village-Međugorje)(D6603).jpg
│   │   ├── 2015-07-06 11.42.52(Međugorje Village-Međugorje)(D6603).jpg
│   │   ├── 2015-07-06 12.30.12(Vrelo-Local community Rodoč I)(D6603).jpg
│   │   ├── 2015-07-06 13.15.32(National Restuarant Cevabdzinica Tima-Irma-Herzegovina-Neretva Canton)(D6603).jpg
│   │   ├── 2015-07-06 13.16.08(Tabačica-Herzegovina-Neretva Canton)(D6603).jpg
│   │   ├── 2015-07-06 15.18.14(Amore mio-Local community Cernica-Šantićeva)(D6603).jpg
│   │   ├── 2015-07-06 16.13.43(Počitelj)(D6603).jpg
│   │   └── 2015-07-06 16.43.17(M 115;M-17-Dračevo)(D6603).jpg
│   ├── Croatia
│   │   ├── 2015-07-02 14.41.17(Zoë-Dubrovnik)(D6603).jpg
│   │   ├── 2015-07-02 21.09.06(Babin Kuk-Dubrovnik)(D6603).jpg
│   │   ├── 2015-07-03 16.20.47(Babin Kuk-Dubrovnik)(D6603).jpg
│   │   ├── 2015-07-04 11.37.47(Zoë-Dubrovnik)(D6603).jpg
│   │   ├── 2015-07-04 12.01.17(Camping Solitudo-Dubrovnik)(D6603).jpg
│   │   ├── 2015-07-04 15.32.01(Dubrovnik-Dubrovnik)(D6603).jpg
│   │   ├── 2015-07-05 13.36.53(Water-Dubrovnik)(D6603).jpg
│   │   └── 2015-07-06 20.47.59(Hotel Royal Princess-Dubrovnik)(D6603).jpg
│   ├── Greece
│   │   ├── 2015-07-18 11.52.37(Knossos-Heraklion Municipal Unit)(D6603).jpg
│   │   ├── 2015-07-18 13.52.23(Dolphins-Heraklion Municipal Unit)(D6603).jpg
│   │   ├── 2015-07-18 13.56.47(1st Community of Heraklion - Central-Heraklion Municipal Unit)(D6603).jpg
│   │   ├── 2015-07-20 12.17.33(Terpsi-Ia Municipal Unit)(D6603).jpg
│   │   ├── 2015-07-20 12.23.40(Thalassia Greek Restaurant-Ia Municipal Unit)(D6603).jpg
│   │   ├── 2015-07-20 12.24.59(39 Steps-Ia Municipal Unit)(D6603).jpg
│   │   ├── 2015-07-20 16.17.41(Thira Municipal Unit)(D6603).jpg
│   │   └── 2015-07-22 12.34.00(Athina Palace-Gazi Municipal Unit)(D6603).jpg
│   ├── Hungary
│   │   ├── 2015-07-10 17.55.35(8th district-Budapest)(D6603).jpg
│   │   ├── 2015-07-10 18.20.30(Corvinus University Budapest New Building-Budapest)(D6603).jpg
│   │   ├── 2015-07-11 09.14.57(8th district-Budapest)(D6603).jpg
│   │   ├── 2015-07-11 10.19.11(Opera-Budapest)(D6603).jpg
│   │   ├── 2015-07-11 11.21.39(Nagy György-Budapest)(D6603).jpg
│   │   ├── 2015-07-11 16.02.04(Kossuth Lajos tér-Budapest)(D6603).jpg
│   │   ├── 2015-07-12 19.48.43(Kálvin tér-Budapest)(D6603).jpg
│   │   ├── 2015-07-12 19.57.11(8th district-Budapest)(D6603).jpg
│   │   ├── 2015-07-13 10.55.01(Great Market Hall-Budapest)(D6603).jpg
│   │   ├── 2015-07-13 11.37.55(5th district-Budapest)(D6603).jpg
│   │   └── 2015-07-13 12.23.55(Eötvös Loránd University Faculty of Law Building B-Budapest)(D6603).jpg
│   └── United Kingdom
│       ├── 2015-07-02 05.19.36(Zone B-Crawley)(D6603).jpg
│       ├── 2015-07-02 06.16.30(Airport Way-Crawley)(D6603).jpg
│       ├── 2015-07-07 13.54.57(Ring Road South-Crawley)(D6603).jpg
│       └── 2015-07-15 09.24.33(London Borough of Camden-London)(D6603).jpg
```

By grouping by Country, I have found the paths sort of separate different vacations...and by having the "landmark-city" in the jpg title after the date/time, you can easily see the different stops you made during you trip.
  
