#' SentinelThumbnailPreview
#' 
#' Preview small sentinel thumbnail images to determine which images are good for use and cloud free
#' @param sentinel.df a dataframe generated from function SentinelSearchToDF()
#' @param thumbnail.dir folder directory to store thumbnail images in
#' @param musr Copernicus Open Access Hub user name (authentication)
#' @param mpass Copernicus Open Access Hub password (authentication)
#' @return Dataframe of search results
#' @export 
SentinelThumbnailPreview <- function(
  sentinel.df=NA,
  thumbnail.dir = NA,
  musr=NA,
  mpass=NA
){
  
  
  if(FALSE){
    sentinel.df=sentdf
    thumbnail.dir = samp_thumbnail_dir
  }
  

  for(i in 1:nrow(sentinel.df)){
    this_thumb <- paste0(as.character(sentinel.df$thumbnail[i]), "Products('Quicklook')/$value")
    
    filename = paste0(thumbnail.dir, "/", sentinel.df$filename[i], ".png")
    
    link <- URLencode(this_thumb, reserved = FALSE, repeated = FALSE)
    this_resp <- GET(link, authenticate(musr, mpass))
    this_img <- content(this_resp)
    if(class(this_img) != "array"){
      print("no preview")
      png(filename, width=6, height=6, units="in",res=300)
      plot(0:1, 0:1, type = "n", axes=FALSE, frame.plot=FALSE, xlab="", ylab="", main=sentinel.df$filename[i])
      text(0.5, 0.5, "No preview")
      dev.off()
      next
    } 
    
    
    # Save output
    png(filename, width=12, height=12, units="in",res=300)
    plot(0:1, 0:1, type = "n", axes=FALSE, frame.plot=FALSE, xlab="", ylab="", main=sentinel.df$filename[i], sub=sentinel.df$summary[i])
    rasterImage(this_img, 0, 0, 1, 1)
    dev.off()

  }

 
  
  
  
}
  