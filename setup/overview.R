# Load required libraries 
library(httr)
library(XML)
library(getPass)
library(dplyr)
library(rvest)
library(openssl)
library(curl)
library(raster)
library(sf)
library(jsonlite)
library(utils)
library(jpeg)




# EXAMPLE SENTINEL API REQUESTS

#-------------------------------------------------------
# Thumbnail preview image
      #  https://scihub.copernicus.eu/dhus/odata/v1/Products('82eece44-7bf1-4a26-ac57-87865dea3ccf')/Products('Quicklook')/$value

#-------------------------------------------------------
# View preview image - full large (usually several MB)
      # https://scihub.copernicus.eu/dhus/odata/v1/Products('2b17b57d-fff4-4645-b539-91f305c27c69')/Nodes('S1A_IW_SLC__1SDV_20160117T103451_20160117T103518_009533_00DD94_D46A.SAFE')/Nodes('preview')/Nodes('quick-look.png')/$value


# https://scihub.copernicus.eu/dhus/odata/v1/Products('fdcd3b33-f206-44c6-8985-e307aade629d')/Nodes('S1A_IW_GRDH_1SDV_20180326T021957_20180326T022026_021180_02469A_239C.SAFE')/Nodes('preview')/Nodes('quick-look.png')/$value

# Example download link
    # https://scihub.copernicus.eu/dhus/odata/v1/Products('2b17b57d-fff4-4645-b539-91f305c27c69')/$value

#===================================

# Setup your account here: https://scihub.copernicus.eu/dhus/#/home
# fields found in the login form.
  musr <- getPass(msg = "Username: ", noblank = FALSE, forcemask = TRUE)
  mpass <- getPass(msg = "Password: ", noblank = FALSE, forcemask = FALSE)
  
    
# Sample arguments for function
  # AOI spatial bounding box (long/lat from raster package) xmin, xmax, ymin, ymax
    #bbox = extent(-128.14381948740458,-128.0907236360836,53.46611510557315,53.495720542528346)
    bbox = extent(-128.413603,-127.857116,53.476091, 53.489031)
    
    
  # Start datetime for sensing date of image (from)
    sensing_date_start = as.POSIXct("03/01/17 23:03:20", "%m/%d/%y %H:%M:%S", tz = "America/Vancouver")
  # End datetime for sensing date of image (to)
    sensing_date_end = strptime("07/01/18 23:03:20", "%m/%d/%y %H:%M:%S", tz = "America/Vancouver")
  # Name of the satellite platform either Sentinel-1, Sentinel-1
    #platformname =  c("Sentinel-1", "Sentinel-2")
    platformname =  c("Sentinel-2")
    
  # Send search request to server
    ?SentinelSearch
    resp <- SentinelSearch(
      musr=musr, # Supplied username
      mpass=mpass, # Supplied password
      bbox=bbox,
      sensing_date_start=sensing_date_start,
      sensing_date_end=sensing_date_end,
      platformname=platformname
    )
 
 # Parse json response into interpretable dataframe
    class(resp) # json "list" generated from function SentinelSearch()
    ?SentinelSearchToDF
    sentdf <- SentinelSearchToDF(
      resp = resp,
      musr=musr, # Supplied username
      mpass=mpass # Supplied password
    )
    nrow(sentdf)
    head(sentdf, 3)
    

# Download thumbnails to sample folder
    samp_thumbnail_dir <- paste0("C:/Users/",Sys.getenv("USERNAME"),"/Desktop/sentinel_thumbnails")
    samp_thumbnail_dir
    
# Create directory if dose not yet exist
    dir.create(samp_thumbnail_dir, showWarnings = FALSE)
    setwd(samp_thumbnail_dir)
    
# Download thumbnails to directory
    SentinelThumbnailPreview(sentinel.df=sentdf,
                             thumbnail.dir = samp_thumbnail_dir,
                             musr=musr,
                             mpass=mpass)

# now minimize R and open thumbnail directory
# manually filter out images that dont fit project criteria - at a coarse scale

  folder_open <- gsub("/", "\\\\", samp_thumbnail_dir)
  shell(paste0("explorer ", folder_open), intern=TRUE)
  
  
# After thumbnails with cloud cover have been removed download the full preview
# images for remaining files - usually 1-6 MB each. These images are larger than 
# the thumbnails and can be used to further filter out good and bad scenes

  
  


