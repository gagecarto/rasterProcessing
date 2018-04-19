# Raster Fixer
## A R script for projecting, resampling and snapping a folder of geoTIFF files

### Getting Started
Fork this repo or get the raw script from here
https://raw.githubusercontent.com/gagecarto/rasterProcessing/master/rasterFixer.R

1) To get started add all the geoTIFF files you would like to process to an empty folder. These files must be stored as geoTIFF and must all intersect

2) Run the script. You can use R or RStudio. You can either copy and paste the entire script in R or open and run using the Source button in RStudio

3) When the script runs a dialog window will open. You might not see it so check your taskbar in case its behind another window or something. Using this dialog box, choose the folder that contains your geoTIFFs. The script will load all rasters and hold them in a list object. After they've all loaded their projections will be assessed.

4) Next you will be given a list of the projections that occurred in your files. Choose one of the projections using the numbers listed above each CRS string. These numbers are listed in double brackets like this [[1]]. Do not type the brackets in, just the number. After this step the shared extent between all files will be calculated.

5) After all datasets have been reprojected, you will be given a list of the cell sizes which occur in the datasets. These will be in the unit of the newly selected master projection. Choose one of the values for cell sizes from the list using the indicator in the double brackets (again, just enter the number, not the brackets etc)

6) You datasets will now be resampled to their shared extent and the cell size you chose. This is handled using the Raster package "resample" function. Choose whether you would like to use bilinear using 1 or nearest neighbor using 2. The script will now resample all the datasets.

7) The last thing that will occur is another dialog window opening. Again, this may be hidden to keep an eye out and look under windows etc. Choose a folder where you would like all the final, processed datasets to be written.

8) Once everything finished there will be an object remaining in memory called "finalRasters". This is a list holding all your finished files. You could now stack these using the stack command like newStack<-stack(finalRasters)

### KNOWN ISSUES  

1) Sometimes when reprojecting rasters from a global projection like World Eckert IV, R ran out of memory. If you see this script crash because of specific memory errors during processing, investigate which raster and CRS caused the problem. Simply reprojecting this one file may fix the issue

This script is definitely in beta form. There are no error handlers or notifications if something goes wrong. We hope to add some error handling in the future. If you find an issue, submit a comment on this github page and we will try and repair the script  
