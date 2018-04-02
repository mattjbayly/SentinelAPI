#' SentinelSearch
#' 
#' Searches available sentinel data for an area of interest and date range
#' @param musr Copernicus Open Access Hub user name (authentication)
#' @param mpass Copernicus Open Access Hub password (authentication)
#' @param bbox Geographic area of interest (a raster extent object)
#' @param sensing_date_start Sensing start (from) datetime 
#' @param sensing_date_end Sensing end (to) datetime 

#' @return Square of the input
#' @export 
SentinelSearch <- function(
  musr=NA,
  mpass=NA,
  bbox=NA,
  sensing_date_start=NA,
  sensing_date_end=NA,
  platformname=NA
  ){

  
  # For testing
  if(FALSE){
    bbox = extent(-128.14381948740458,-128.0907236360836,53.46611510557315,53.495720542528346)
    sensing_date_start = as.POSIXct("03/01/18 23:03:20", "%m/%d/%y %H:%M:%S", tz = "America/Vancouver")
    sensing_date_end = strptime("03/30/18 23:03:20", "%m/%d/%y %H:%M:%S", tz = "America/Vancouver")
    platformname =  c("Sentinel-1", "Sentinel-2")

  }
  
  

  
  base_string <- "https://scihub.copernicus.eu/dhus/search?q="
  
  #-----------------------------------------------------
  # Build string for geographic area of interest
  if(class(bbox) == "Extent"){
    print("AOI provided")
  
    
    # If bbox is extent object
    if(class(bbox)=="Extent"){
      pbbox <- as(bbox, "SpatialPolygons")
      sf.pbbox <- st_as_sf(pbbox)
      if(is.na(st_crs(sf.pbbox))){
        st_crs(sf.pbbox) <- 4326
      }
      sf.pbbox <- st_transform(sf.pbbox, 4326)
      coords <- st_coordinates(sf.pbbox)
      # Coordinates to strin
      pt_str <- paste0(coords[1,1], "%20", coords[1,2], ",",
                       coords[2,1], "%20", coords[2,2], ",",
                       coords[3,1], "%20", coords[3,2], ",",
                       coords[4,1], "%20", coords[4,2], ",",
                       coords[1,1], "%20", coords[1,2], "")

      begpoly <- "footprint:%22Intersects(POLYGON(("
      endpoly <- ")))"
      pt_str <- paste0(begpoly, pt_str, endpoly)
      
    }
    
  } else {
    print("AOI not provided")
    pt_str <- ""
  }
  # End of area of interest intersection
  
  
  
  
  #-----------------------------------------------------
  # Start of time frame select
  
  #paste0(base_string, pt_str, "%22")
 
  if(!(is.na(sensing_date_start))){
    
    # Test to make sure user provides datetime object
    if(class(sensing_date_start)[2] != "POSIXt" | class(sensing_date_end)[2] != "POSIXt"){
      stop("Start datetime and end datetime must both be POSIXct objects")
    } 
    
    print("Switching tz to UTC")
    start_time <- as.POSIXct(sensing_date_start)
    attr(start_time, "tzone") <- "UTC"
    start_time <- paste0(as.character(start_time), "0Z")
    start_time <- gsub(" ", "T", start_time)
    print(start_time)
    
    end_time <- as.POSIXct(sensing_date_end)
    attr(end_time, "tzone") <- "UTC"
    end_time <- paste0(as.character(end_time), "0Z")
    end_time <- gsub(" ", "T", end_time)
    print(end_time)
    
    
    datetime <- paste0("(%20beginPosition:[",start_time,"%20TO%20", 
                       end_time, "]%20AND%20endPosition:[",start_time,
                       "%20TO%20",end_time, "]%20)")
    
  } else {
    datetime <- ""
  }
  # end of datetime string
  #-------------------------------------------------------

  
  #-----------------------------------------------------
  # Add which satellite e.g. sentinel-1 or sentinel-2 or 3
  if(!(is.na(platformname[1]))){
    if(length(platformname)==1){
      print(paste0("platform:",platformname))
      if(platformname == "Sentinel-1"){
        platformname_string = "(platformname:Sentinel-1)"
      }
      if(platformname == "Sentinel-2"){
        platformname_string = "(platformname:Sentinel-2)"
      }
    } else {
      print(paste0("platforms:",platformname))
      platformname_string="(platformname:Sentinel-1)%20OR%20(platformname:Sentinel-2)"
    }
  } else {
    platformname_string = ""
  }
  # End build platform string query
  #-----------------------------------------------------
  
  
  #=====================================================
  #=====================================================
  # Build final string for http request
  base_string <- "https://scihub.copernicus.eu/dhus/search?q="
  build_string <- paste0(base_string, pt_str)
  
  if(pt_str != "" & (datetime != ""| platformname_string != "")){
    # Make connector
    build_string <- paste0(build_string, "%22%20AND%20")
  }
  
  # Datetime range
  build_string <- paste0(build_string, datetime)
  if(datetime != "" & (platformname_string != "")){
    # Make connector
    build_string <- paste0(build_string, "%20AND%20")
  }
  
  # Platform range
  build_string <- paste0(build_string, platformname_string)
  
  # end of build http query url string
  #=====================================================
  
  #----------------------------------------------------
  #Start: Make http request with username and password
  #print(build_string)
  # Send request to server
  this_resp <- GET(build_string, authenticate(musr, mpass))
  if(status_code(this_resp) != 200){
    stop("Error bad status code")
  } else {
    print("Connection Successful - 200")
  }
  
  class(this_resp)
  # Parse response as xml
  p_resp <- read_xml(this_resp)
  # Convert xml document to json
  class(p_resp)
  doc <- xmlParse(p_resp)
  class(doc)
  a <- xmlToList(doc)
  class(a)
  #jsonlite::toJSON(a, pretty=TRUE)
  library(jsonlite)
  mjson <-  fromJSON(jsonlite::toJSON(a, pretty=TRUE))
  
  mjson$entry.8
  mjson$entry.8$str.18
  
  # Return number of scenes to user (print)
  print(mjson$subtitle)
  
  return(mjson)
  
  
  
} # end of function

