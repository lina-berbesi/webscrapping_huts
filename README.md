**Webscrapping huts capacity by using huts links available through an API**
- Download the hut's links list from [data.govt.nz](https://catalogue.data.govt.nz/dataset/doc-huts3/resource/5af60b27-b2b0-425d-8c09-98012e523848?inner_span=True) using [CKANr](https://github.com/ropensci/ckanr)
- Transforming easting and northing UTM into latitude and longitude
- Scraping data about number of beds/bunks using [rvest](https://github.com/tidyverse/rvest)
- Doing a heatmap to identify the regions with the highest number of bunks

![huts](https://github.com/lina-berbesi/webscrapping_huts/blob/main/doc_huts.png)
