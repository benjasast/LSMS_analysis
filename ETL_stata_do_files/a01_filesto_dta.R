library("foreign")

dir1 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/albania_2008/Data_2008/"
dir2 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/albania_2012/Data_LSMS2012/"
dir3 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/ecuador_1995/"
dir4 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/ecuador_1998/"
dir5 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/ecuador_1999/"
dir6 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/ecuador_2006"
dir7 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/ecuador_2014/"
dir8 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/ecuador_2014/ECV\ 6R\ BASES\ DE\ DATOS\ PRIMARIAS/"
dir9 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/nicaragua_2001/"
dir10 <- "/Users/bsastrakinsky/Dropbox/LSMS_Compilation/Data/nicaragua_2005/"

dir <- c(dir1,dir2,dir3,dir4,dir5,dir6,dir7,dir8,dir9,dir10)



for(l in 1:10){
  
  
  "Grab all files"
  setwd(dir[l])
  path = dir[l]
  file.names <- dir(path, pattern =".sav")
  names <- gsub(file.names, pattern=".sav$", replacement=".dta")
  
  
  
  for(i in 1:length(file.names)){
    print(file.names[i])
    data <- read.spss(file.names[i], to.data.frame=TRUE)
    write.dta(data, names[i])
    rm(data)  
    
  }

}

