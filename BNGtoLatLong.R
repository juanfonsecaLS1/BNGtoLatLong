library(rvest)
library(xml2)
library(dplyr)
library(magrittr)
library(stringr)


### Read Coordinates in BNG ###

base.coordinates <- read.table("Easting_Northing.csv",sep = ",", quote="\"", comment.char="")$V1

x<-base.coordinates[[1]]


### Function to read get the lat long ###

BNGtoLongLat<-function(x){
  Easting<-str_extract(x,"\\d+(?=\\s)")
  Northing<-str_extract(x,"(?<=\\s)\\d+")
  path<-paste0("http://webapps.bgs.ac.uk/data/webservices/CoordConvert_LL_BNG.cfc?method=BNGtoLatLng&easting=",
  Easting,
  "&northing=",
  Northing)
  line<-xml2::read_html(path)%>%
  rvest::html_text()
  Long<-str_extract(line,"(?<=\"(Longitude|LONGITUDE)\":).+(?=,\"NORTHING)")
  Lat<-str_extract(line,"(?<=\"(Latitude|LATITUDE)\":).+(?=\\})")

 y<-data.frame(original = x,
                new = paste(Lat,Long,sep = ", "))
  return(y)
}


####running the function for all coordinates

df.Coordinates<-do.call(rbind,lapply(base.coordinates,BNGtoLongLat))
write.csv2(df.Coordinates,file = "New_coordinates.csv",quote = FALSE)
