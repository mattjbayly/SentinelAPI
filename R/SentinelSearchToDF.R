#' SentinelSearchToDF
#' 
#' Parse Sentinel Search json list object to dataframe with key fields for each image
#' @param resp JSON "list" object generated from function SentinelSearch()
#' @param musr Copernicus Open Access Hub user name (authentication)
#' @param mpass Copernicus Open Access Hub password (authentication)
#' @return Dataframe of search results
#' @export 
SentinelSearchToDF <- function(
  resp=NA, musr=NA, mpass=NA
){
  
  
  # FOR DEV AND TESTING
  if(FALSE){
    resp = resp
  }
  

  
  # Total count of images
  n_results <- as.numeric(resp$totalResults)
  #Links to all search items
  page_links <- names(resp)[grepl("link", names(resp))]
  
  
  
  #=====================================
  # Build df for pg1 entries
  df <- data.frame()
  
  
  # Loop through pages
  if(n_results < 10){
    page_seq <- 0
  } else {
    # Zero offset
    page_seq <- seq(from=0, to=(10*round(n_results/10, 0)), by=10)
    page_seq <- page_seq - 1
    page_seq[1] <- 0
  }
  
  
  for(i in page_seq){
    #print(i)
    page1 <- unlist(resp$link)[3]
    # Update page and row index
    page2 <- gsub("&start=0&rows=10", paste0("&start=",i+1,"&rows=10"), page1)
    print(paste0("Rows ", i, " of ", n_results))
    # Fix URL
    # Send url to server
    link <- URLencode(page2, reserved = FALSE, repeated = FALSE)
    this_resp <- GET(link, authenticate(musr, mpass))
    
    #---------------------------------------------------
    if(status_code(this_resp) != 200){
      stop("Error bad status code")
    }
    # Parse response as xml
    p_resp <- read_xml(this_resp)
    # Convert xml document to json
    doc <- xmlParse(p_resp)
    a <- xmlToList(doc)
    #jsonlite::toJSON(a, pretty=TRUE)
    mjson <-  fromJSON(jsonlite::toJSON(a, pretty=TRUE))
    
    
    # Get list of images on page
    names(mjson)
    mimages <- names(mjson)[grepl("entry", names(mjson))]
    
    
    #======================================
    # Extract target fields
    
    for(e in 1:length(mimages)){
      # Single entry
      this_entry <- mjson[mimages[e]]
      entry_unlist <- unlist(this_entry)
      this_beginposition <- entry_unlist[which(grepl("beginposition", entry_unlist))-1]
      this_summary <- entry_unlist[which(grepl("summary", names(entry_unlist)))]
      this_platformname <- entry_unlist[which(grepl("platformname", entry_unlist))-1]
      this_title <- entry_unlist[which(grepl("title", names(entry_unlist)))]
      this_filename <- entry_unlist[which(grepl("filename", entry_unlist))-1]
      this_download  <- entry_unlist[which(grepl("link", names(entry_unlist)))[1]]
      this_thumbnail <- entry_unlist[which(grepl("icon", entry_unlist))-1]
      this_id <- entry_unlist[which(grepl("id", names(entry_unlist)))]
      this_instrumentname <- entry_unlist[which(grepl("instrumentname", entry_unlist))-1]
      this_size <- entry_unlist[which(grepl("size", entry_unlist))-1]
      this_uuid <- entry_unlist[which(grepl("uuid", entry_unlist))-1]
      
      
      this_datetime <- gsub("T", " ", this_beginposition)
      this_datetime <- gsub("Z", "", this_datetime)
      this_datetime = as.POSIXct(this_datetime, "%Y-%m-%d %H:%M:%S", tz = "UTC")
      
      if(length(this_download) == 0){
        this_download = NA
      }
      
      
      vec <- c(beginposition =this_beginposition,datetime = this_datetime, instrumentname =this_instrumentname,platformname =this_platformname,title =this_title,filename =this_filename,download =this_download,thumbnail =this_thumbnail,id =this_id, summary =this_summary,size =this_size,uuid =this_uuid)
      names(vec)  <- NULL
      this_row <- data.frame(t(vec))
      
      df <- rbind(df, this_row)
    
    } # end of results on page 
    #=====================================================
    rm(mjson)
    rm(link)
    rm(this_resp)
    
    #print(paste0("nrow df ", nrow(df)))

  } # end of page with 10 entries
  #=====================================================
  
  #nrow(df)
  #length(unique(df$X12))

  # fix row names
  colnames(df)<-c("beginposition","datetime" , "instrumentname","platformname","title","filename","download","thumbnail","id", "summary","size","uuid")
  
  duplicated(df$id)
  
  if(nrow(df) != n_results){
    stop("unexpected df length")
  }
  
  # Fix datetime column
  this_datetime <- gsub("T", " ", df$beginposition)
  this_datetime <- gsub("Z", "", this_datetime)
  this_datetime = as.POSIXct(this_datetime, "%Y-%m-%d %H:%M:%S", tz = "UTC")
  df$datetime <- this_datetime
  

  
  return(df)
  
  
}
  