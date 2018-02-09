require('raster')

# workingDirectory<-choose.dir()
workingDirectory<-'C:\\Users\\Josh\\Desktop\\travisTesting'

rastersToProcess<-list.files(workingDirectory,pattern='.tif$')

rastersToProcessHolder<-list()
availableProjections<-list()
resolutions<-list()
extents<-list()

masterProjection<-''
masterResolution<-''

importRasters <- function (){
  for(i in 1:length(rastersToProcess)){
    print(i)
    thisRaster<-raster(paste0(workingDirectory,'\\',rastersToProcess[i]))
    rastersToProcessHolder[[i]]<<-thisRaster
    availableProjections[[i]]<<-thisRaster@crs
    resolutions[[i]]<<-res(thisRaster)
    extents[[i]]<-thisRaster@extent
  }
  checkPrj()
}


checkPrj <- function(){
  uniqueProjections<<-unique(availableProjections)
  if(length(uniqueProjections)>1){
    print(unique(availableProjections))
    print(paste0('The datasets you imported had ',length(uniqueProjections),' unique projections. Choose the projections you would
                 like to use by entering a number below which references the index number shown in the brackets above ([[]])'))
    masterProjection <<- readline("Which projection would you like to use?")
    masterProjection<<-as.numeric(masterProjection)
    masterProjection<<-uniqueProjections[[masterProjection]]
    print(paste0('Great! ',masterProjection,' is the master projection for this processing. Reprojecting all datasets to match'))
    reprojectRasters()
  } else{
    masterProjection<<-uniqueProjections[[1]]
    print(paste0('Nice job preparing your data! All datasets have the same projection of ',masterProjection,' moving on to check data resolutions'))
    checkCellSizes()
  }
}

reprojectRasters<-function(){
  for(i in 1:length(rastersToProcessHolder)){
    thisRaster<-rastersToProcessHolder[[i]]
    thisCrs<<-thisRaster@crs
    thisRasterName<-thisRaster@data@names
    resolutions[[i]]<<-res(thisRaster)
    extents[[i]]<-thisRaster@extent
    if(thisCrs@projargs!=masterProjection@projargs){
     print(paste0(thisRasterName,' has a projection different than what you have selected.. Reprojecting now..'))
      thisRaster<-projectRaster(thisRaster,crs=masterProjection)
      rastersToProcessHolder[[i]]<<-thisRaster
      resolutions[[i]]<<-res(thisRaster)
      extents[[i]]<-thisRaster@extent
    } else{
      print(paste0(thisRasterName,' has the master projection.. Nice! Move along then..'))
    }
  }
  checkCellSizes()
}

checkCellSizes<-function(){
  uniqueResolutions<<-unique(resolutions)
  if(length(uniqueResolutions)>1){
    print(uniqueResolutions)
    print(paste0('The datasets you imported had ',length(uniqueResolutions),' unique resolutions (cell sizes). Choose the resolution you would
                 like to use by entering a number below which references the index number shown in the brackets above ([[]])'))
    masterResolution <<- readline("Which resolution would you like to use?")
    masterResolution<<-as.numeric(masterResolution)
    masterResolution<<-uniqueResolutions[[masterResolution]]
    print(paste0('Great! ',toString(masterResolution),' is the master resolution for this processing. Changing resolution of all datasets to match'))
    setCellSizes()
  } else{
    masterResolution<<-uniqueResolutions[[1]]
    print(paste0('Nice job preparing your data! All datasets have the same resolution of ',masterResolution,' moving on to check raster extents'))
  }
}

setCellSizes<- function(){
  for(i in 1:length(rastersToProcessHolder)){
    thisRaster<-rastersToProcessHolder[[i]]
    thisResolution<<-res(thisRaster)
    thisRasterName<-thisRaster@data@names
    resolutionsDontMatch<-thisResolution!=masterResolution
    if(resolutionsDontMatch[1] | resolutionsDontMatch[2]){
     print(paste0(thisRasterName,' has a resolution different than what you have selected.. Changing now..'))
     res(thisRaster)<-masterResolution
     rastersToProcessHolder[[i]]<<-thisRaster
    } else{
      print(paste0(thisRasterName,' has the master resolution.. Nice! Move along then..'))
    }
  }
}


importRasters()
