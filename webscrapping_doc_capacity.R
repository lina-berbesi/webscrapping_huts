

suppressPackageStartupMessages(library(ckanr))
suppressPackageStartupMessages(library(proj4))
suppressPackageStartupMessages(library(rvest))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(openxlsx))
suppressPackageStartupMessages(library(purrr))

# Getting list with links of huts from data.govt.nz API
# https://www.doc.govt.nz/parks-and-recreation/places-to-stay/stay-in-a-hut/ 
# https://catalogue.data.govt.nz/dataset/doc-huts3/resource/5af60b27-b2b0-425d-8c09-98012e523848?inner_span=True

ckanr::ckanr_setup("https://catalogue.data.govt.nz")

dataset_id<-"5af60b27-b2b0-425d-8c09-98012e523848"

api_res <- ckanr::resource_show(id = dataset_id, as = "table")

doc_huts_links<- ckanr::ckan_fetch(api_res$url,format=api_res$format)

doc_huts_links_sub<-doc_huts_links %>% dplyr::select(staticLink,locationString,region,name,x,y) %>% 
                                       rename(link=staticLink,easting=x,northing=y) %>% 
                                       mutate(row=row_number())

# Changing UTM(Universal Transverse Mercator) projections to lat lon

proj4 <- "+proj=tmerc +lat_0=0 +lon_0=173 +k=0.9996 +x_0=1600000 +y_0=10000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs "

x_y <- doc_huts_links_sub %>% dplyr::select('easting','northing') 

lon_lat <- proj4::project(x_y, proj4, inverse = TRUE) 

lon_lat_fnl <- data.frame(Longitude = lon_lat$x, Latitude = lon_lat$y) %>% mutate(row=row_number())

doc_huts_final <- doc_huts_links_sub %>% left_join(y=lon_lat_fnl,by=c("row"="row")) %>% dplyr::select(-c("row"))

head(doc_huts_final)

# Web scrapping Huts Capacity - It takes between 7 and 10 mins

start_time<-Sys.time()

links<-doc_huts_links_fnl$link

pages <- links %>% purrr::map(xml2::read_html)

hut_bunks <- pages %>% 
  purrr::map(. %>% 
            html_nodes(".hut-bunks") %>% 
            html_text()
  )

bunks<-regmatches(hut_bunks, gregexpr("[[:digit:]]+", hut_bunks))
                 
end_time<-Sys.time()

end_time-start_time

unlist(bunks)

# Writing output into a csv

bunks_df<-data.frame(Y=doc_huts_final[,c("northing")],
                     X=doc_huts_final[,c("easting")],
                     bunks=I(bunks))

head(bunks_df)

doc_huts_capacity<-doc_huts_final %>% left_join(bunks_df,by=c("northing"="Y","easting"="X"))

View(doc_huts_capacity)

doc_huts_capacity %>% filter(duplicated(link) & duplicated(link,fromLast = TRUE))

write.csv(doc_huts_capacity,"Documents/Github/webscrapping_doc/doc_huts_capacity.csv", fileEncoding = "UTF-8",row.names=FALSE)

 