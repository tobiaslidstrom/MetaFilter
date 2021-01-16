# MetaFilter
Customizable metadata filters for exporting images in Adobe Lightroom

#### Features
  * Export images with or without metadata
  * Customizable XMP, EXIF and IPTC data
  * User defined metadata

## Setup
#### Requirements
  * Adobe Lightroom 3 or later
  * Exiftool (included)

#### Installation
  * Download the [latest release](/../../releases/)
  * Extract the content to a folder
  * In Lightroom select `File` > `Plug-in Manager` and click `Add Plugin`
  * Select the folder where you extracted the files earlier

## Usage
In order to export images with MetaFilter, follow these steps:
  * Select `File` > `Export` and choose MetaFilter in the options
  * Customize to your needs and click `Export`
  * To save your settings you can save it as a preset

#### Advanced Customization
If you want to add or change metadata filters you can do so by editing the `metadata.xml` file that can be found in the `lib` folder.

You can use [XMP](https://www.exiftool.org/TagNames/XMP.html), [EXIF](https://www.exiftool.org/TagNames/EXIF.html) and [IPTC](https://www.exiftool.org/TagNames/IPTC.html) data.

## Licensing
This project is licensed under the [MIT License](LICENSE).
