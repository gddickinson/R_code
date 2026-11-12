# data processing
library(foreign) # for reading dbfs
library(dplyr)
library(magrittr)
library(tidyr) 
library(ggplot2)
library(gridExtra) # to arrange grid plots

# spatial
library(raster)
library(rasterVis)
library(rgdal)
library(dismo) #map raster on Google Map

# data location
url<-"http://qgis.org/downloads/data/qgis_sample_data.zip"

mydir<-"C:/Users/g_dic/junk_deleteContents"
temp<-tempfile(tmpdir=mydir, fileext=".zip")
download.file(url, temp)
unzip(temp, exdir=mydir)
unlink(temp) #delete the zip file

# Grab the name of the file path
fpath<-list.files(path = mydir, full.names = TRUE, pattern = "qgis_sample_data")
fpath<-gsub("/", "\\\\", fpath)

# Read in landcover raster
landusepath<-paste(fpath, "raster\\landcover.img", sep="\\")
landuse.raw<-raster(landusepath)
plot(landuse.raw, axes=FALSE)

vals<-unique(values(landuse.raw))
recl<-matrix(c(vals, c(0, rep(1, 6), 9, 1,1, 13)),ncol=2)
recl

#reclassify
landuse<-reclassify(landuse.raw, rcl=recl)
plot(landuse, legend=FALSE, axes=FALSE)

# Regions polygon shapefile
regionpath<-paste(fpath, "shapefiles", sep="\\")
region<-readOGR(dsn=regionpath, layer="regions") 

# we will use ggplot to plot the regions
ggplot()+geom_polygon(data=region,  aes(x=long, y=lat, group=group), 
                      fill="cadetblue", color="grey")+
  coord_equal()+xlim(c(-5000000, 5000000))+ylim(c(1000000, 8000000))


# Create a subset with our regions of interest
myregions<-c( "Anchorage", "Yukon-Koyukuk", "North Slope")
region.sm<-region[region$NAME_2 %in% myregions,]

# crop, rasterize and mask 
cr<-crop(landuse, region.sm)
fr<-rasterize(region.sm, cr)
lr<-mask(x=cr, mask=fr)


# let's map those pieces so you can see the result. Since I just
# want the raster with no legend/axes etc I'm creating a function
# to strip the plot

nakedMap<-function(dat, title=""){
  gplot(dat)+geom_tile(aes(fill=value))+
    ggtitle(title)+
    coord_equal()+ 
    scale_x_continuous(expand = c(0,0)) + 
    scale_y_continuous(expand = c(0,0)) +
    theme(line = element_blank(),
          line = element_blank(),
          axis.text=element_blank(),
          axis.title=element_blank(),
          legend.position = "none")
}


cr.plot<-nakedMap(cr, title="Cropped")
fr.plot<-nakedMap(fr, title="Regions")
lr.plot<-nakedMap(lr, title="Masked")

grid.arrange(cr.plot, fr.plot, lr.plot, ncol=3) #use package gridExtra

#make nicer map

# centroids for the labels
centroids<-cbind(coordinates(region.sm), region.sm@data)
names(centroids)[1:2]<-c("x", "y")

# use gplot (not ggplot) from rasterVis
# geom_tile adds the raster, geom_polygon adds the regions
# geom_text adds the labels at the centroids
gplot(lr)+
  geom_tile(aes(fill=factor(value, labels=c("Water", "Green", "Shrubland", "Urban"))), alpha=0.8)+
  scale_fill_manual(values = c("steelblue3", "forestgreen", "ghostwhite", "red"),
                    name= "Land use code")+
  geom_polygon(data=region.sm, aes(x=long, y=lat, group=group), 
               fill=NA,color="grey50", size=1)+
  geom_text(data=centroids, aes(x=x, y=y, label=NAME_2), fontface="bold")+
  coord_equal()



# Elevation raster
elevpath<-paste(fpath, "raster/SR_50M_alaska_nad.tif", sep="\\")
elev<-raster(elevpath)

# Are the resolutions the same
res(landuse.raw)
## [1] 3280 3280
res(elev)
## [1] 7181.354 7181.354

# No, we will use resample to make the same resolution
# NOTE: this takes a minute or so to run
elev<-resample(elev, landuse.raw, method="ngb")

# Check again to see that the resolutions match
res(landuse.raw)
## [1] 3280 3280
res(elev)
## [1] 3280 3280

# we manually selected an extent to crop to
ext<-extent(-2500000, 2500000, 2000000, 7650000)

elev<-crop(elev, ext)
landuse.raw<-crop(landuse.raw, ext)

landelev<-brick(landuse.raw, elev)
# to create a RasterStack instead
# stack(landuse.raw, elev)

# This is creating a new raster where our first raster
# layer in the brick (x) has a value of 1 or 2 and our 
# second layer in the brick (y) is greater than or equal to 200.

elevForest<-overlay(landelev, fun = function(x, y) (x == 1 | x == 2) & y > 200)

# Create our gmap
g<-gmap(x = elevForest, type = "hybrid")

# Reproject our raster so it's the same projection as our gmap(). 
# NOTE: the default method is bilinear which is not appropriate here
# where we have categorical values
elevForest.prj<-projectRaster(from = elevForest, to=g, method="ngb")

# I want the 0 values to be NA so they don't get mapped
elevForest.prj[elevForest.prj == 0]<-NA