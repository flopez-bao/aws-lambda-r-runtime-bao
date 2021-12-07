library(magrittr)
handler <- function(userid) {
     # link to the API output as a JSON file
  url_json <- "https://jsonplaceholder.typicode.com/posts"
  
  # get the raw json into R
  raw_json <- jsonlite::fromJSON(url_json)
  
  #filter out for the userid
  raw_json %<>% 
    dplyr::filter(userId == userid) %>%
    dplyr::select(body)
  
  #return data
  list(response = jsonlite::toJSON(raw_json))
}
