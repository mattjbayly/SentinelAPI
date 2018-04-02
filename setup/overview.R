library(httr)
library(XML)
library(getPass)
library(dplyr)
library(rvest)
library(openssl)
library(curl)
library(raster)
library(sf)

# Part 1: Build search query
# Part 2: Export search results
# Part 3: Preview search result images
# Part 4: Download target search images



#=======================================================
# Part 1: Build search query




# Results are zero indexd
# Displaying 0 to 9 of 5948862 total results. Request done in 0 seconds.

# Full thumbnail preview image
      #  https://scihub.copernicus.eu/dhus/odata/v1/Products('82eece44-7bf1-4a26-ac57-87865dea3ccf')/Products('Quicklook')/$value

# View preview image
      # https://scihub.copernicus.eu/dhus/odata/v1/Products('2b17b57d-fff4-4645-b539-91f305c27c69')/Nodes('S1A_IW_SLC__1SDV_20160117T103451_20160117T103518_009533_00DD94_D46A.SAFE')/Nodes('preview')/Nodes('quick-look.png')/$value


# https://scihub.copernicus.eu/dhus/odata/v1/Products('fdcd3b33-f206-44c6-8985-e307aade629d')/Nodes('S1A_IW_GRDH_1SDV_20180326T021957_20180326T022026_021180_02469A_239C.SAFE')/Nodes('preview')/Nodes('quick-look.png')/$value

# Example download link
    # https://scihub.copernicus.eu/dhus/odata/v1/Products('2b17b57d-fff4-4645-b539-91f305c27c69')/$value

# fields found in the login form.
musr <- getPass(msg = "Username: ", noblank = FALSE, forcemask = TRUE)
mpass <- getPass(msg = "Password: ", noblank = FALSE, forcemask = FALSE)

  
# Sample arguments for function
  bbox = extent(-128.14381948740458,-128.0907236360836,53.46611510557315,53.495720542528346)
  sensing_date_start = as.POSIXct("03/01/18 23:03:20", "%m/%d/%y %H:%M:%S", tz = "America/Vancouver")
  sensing_date_end = strptime("03/30/18 23:03:20", "%m/%d/%y %H:%M:%S", tz = "America/Vancouver")
  platformname =  c("Sentinel-1", "Sentinel-2")
  
  #' @export 
  resp <- SentinelSearch(
    musr=musr,
    mpass=mpass,
    bbox=bbox,
    sensing_date_start=sensing_date_start,
    sensing_date_end=sensing_date_end,
    platformname=platformname
  )
 
 
# Sample Image with product ID
# https://scihub.copernicus.eu/dhus/odata/v1/Products('2b17b57d-fff4-4645-b539-91f305c27c69')


# Full request 
# https://scihub.copernicus.eu/dhus/api/stub/products?filter=(%20footprint:%22Intersects(POLYGON((-128.13151576238064%2053.48235577606505,-128.10586020725893%2053.48235577606505,-128.10586020725893%2053.49377119331655,-128.13151576238064%2053.49377119331655,-128.13151576238064%2053.48235577606505)))%22%20)%20AND%20(%20beginPosition:[2018-03-01T00:00:00.000Z%20TO%202018-03-30T23:59:59.999Z]%20AND%20endPosition:[2018-03-01T00:00:00.000Z%20TO%202018-03-30T23:59:59.999Z]%20)%20AND%20%20%20(platformname:Sentinel-1)%20OR%20(platformname:Sentinel-2)&offset=0&limit=25&sortedby=beginposition&order=desc





