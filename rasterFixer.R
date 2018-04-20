if(!require('raster')){
  install.packages("raster")
  require(raster)
} else{
  require('raster')
}

if(!require('rgdal')){
  install.packages("rgdal")
  require(rgdal)
} else{
  require('rgdal')
}



workingDirectory<<-choose.dir(caption="Select the folder that contains the geoTIFF files you'd like to process")

exportDirectory<<-choose.dir(caption="Choose an empty folder where you would like all the final, processed files written upon completion")

rastersToProcess<-list.files(workingDirectory,pattern='.tif$')

rastersToProcessHolder<-list()
availableProjections<-list()
resolutions<-list()
extents<-list()
finalExtent<-list()

masterProjection<-NULL
masterResolution<-NULL

dummyRaster<-raster()


importRasters <- function (){
  for(i in 1:length(rastersToProcess)){
    print(i)
    thisRaster<-raster(paste0(workingDirectory,'\\',rastersToProcess[i]))
    rastersToProcessHolder[[i]]<<-thisRaster
    availableProjections[[i]]<<-thisRaster@crs
    resolutions[[i]]<<-res(thisRaster)
    extents[[i]]<<-thisRaster@extent
  }
  checkPrjs()
}


checkPrjs <- function(){
  uniqueProjections<<-unique(availableProjections)
  if(length(uniqueProjections)>1){
    print(unique(availableProjections))
    print(paste0('The datasets you imported had ',length(uniqueProjections),' unique projections. Choose the projections you would
                 like to use by entering a number below which references the index number shown in the brackets above ([[]])'))
    masterProjection <<- readline("Which projection would you like to use?")
    masterProjection<<-as.numeric(masterProjection)
    masterProjection<<-uniqueProjections[[masterProjection]]
    projection(dummyRaster) <<- masterProjection
    print(paste0('Great! ',masterProjection,' is the master projection for this processing. Reprojecting all datasets to match'))
    reprojectRasters()
  } else{
    masterProjection<<-uniqueProjections[[1]]
    projection(dummyRaster) <<- masterProjection
    print(paste0('Nice job preparing your data! All datasets have the same projection of ',masterProjection,' moving on to check data resolutions'))
    reprojectRasters()
  }
}

reprojectRasters<-function(){
  for(i in 1:length(rastersToProcessHolder)){
    gc()
    # thisRaster<-rastersToProcessHolder[[i]]
    # thisCrs<<-thisRaster@crs
    thisCrs<-rastersToProcessHolder[[i]]@crs
    thisRasterName<-rastersToProcessHolder[[i]]@data@names
    resolutions[[i]]<<-res(rastersToProcessHolder[[i]])
    extents[[i]]<<-rastersToProcessHolder[[i]]@extent
    if(thisCrs@projargs!=masterProjection@projargs){
     print(paste0(thisRasterName,' has a projection different than what you have selected.. Reprojecting now..'))
      rastersToProcessHolder[[i]]<-projectRaster(rastersToProcessHolder[[i]],crs=masterProjection)
      resolutions[[i]]<<-res(rastersToProcessHolder[[i]])
      extents[[i]]<<-rastersToProcessHolder[[i]]@extent
    } else{
      print(paste0(thisRasterName,' has the master projection.. Nice! Move along then..'))
    }
  }
  checkExtents()
}

checkExtents<-function(){
  for(i in 1:length(extents)){
      thisExtent<-extents[[i]]
      if(i==1){
        finalExtent$xmin<<-thisExtent@xmin
        finalExtent$xmax<<-thisExtent@xmax
        finalExtent$ymin<<-thisExtent@ymin
        finalExtent$ymax<<-thisExtent@ymax
      } else{
        ifelse(thisExtent@xmin>finalExtent$xmin,finalExtent$xmin<<-thisExtent@xmin,NA)
        ifelse(thisExtent@xmax<finalExtent$xmax,finalExtent$xmax<<-thisExtent@xmax,NA)
        ifelse(thisExtent@ymin>finalExtent$ymin,finalExtent$ymin<<-thisExtent@ymin,NA)
        ifelse(thisExtent@ymax<finalExtent$ymax,finalExtent$ymax<<-thisExtent@ymax,NA)
      }
  }
  extent(dummyRaster)<<-c(finalExtent$xmin,finalExtent$xmax,finalExtent$ymin,finalExtent$ymax)
  chooseCellSize()
}

chooseCellSize<-function(){
  uniqueResolutions<-unique(resolutions)
  if(length(uniqueResolutions)>1){
    print(uniqueResolutions)
    print(paste0('The datasets you imported had ',length(uniqueResolutions),' unique resolutions. Choose the resolution you would
                 like to use by entering a number below which references the index number shown in the brackets above ([[]])'))
    masterResolution <<- readline("Which resolution would you like to use?")
    masterResolution<<-as.numeric(masterResolution)
    masterResolution<<-uniqueResolutions[[masterResolution]]
    print(paste0('Great! ',toString(masterResolution),' is the master resolution for this processing. Changing all datasets to match'))
  } else{
    masterResolution<<-uniqueResolutions[[1]]
    print(paste0('Nice job preparing your data! All datasets have the same resolution of ',masterResolution,' moving on to snap rasters'))
  }
  res(dummyRaster)<<-masterResolution
  snapExtents()
}

snapExtents<-function(){
  snappingMethod <- readline("Which method of resampling would you like to use? Type 1 for bilinear or 2 for nearest neighbor")
  if(snappingMethod=='2'){
    snappingMethod<-'ngb'
  } else{
    snappingMethod<-'bilinear'
  }
  for(i in 1:length(rastersToProcessHolder)){
    print(paste0('snapping raster ',i,' of ',length(rastersToProcessHolder)))
    flush.console()
    rastersToProcessHolder[[i]]<<-resample(rastersToProcessHolder[[i]],dummyRaster,method=snappingMethod)

    print(paste0('saving snapped raster final raster ',i,' of ',length(rastersToProcessHolder)))
    flush.console()
    thisRaster<-rastersToProcessHolder[[i]]
    thisRasterName<-thisRaster@data@names
    writeRaster(rastersToProcessHolder[[i]],paste0(exportDirectory,'\\',thisRasterName,'Ed.tif'),overwrite=TRUE)
  }
  writeFinalFiles()
}

writeFinalFiles<-function(){
  finishedRasters<<-rastersToProcessHolder
  rm(rastersToProcessHolder)
  saveRDS(finishedRasters,paste0(exportDirectory,'\\','finalRastersList.rds'))
  print('PROCESSING FINISHED... Final, processed rasters have been written with "Ed" on their filename to the export directory you selected')
  print('Additionally, final rasters are now stored and available in a R list object called finishedRasters. This object has been saved as a RDS file in your selected export directory.')
}

importRasters()
