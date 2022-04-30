
# OpenSea 랭킹 Top 100

library(dplyr)
library(rvest)

URL <- "https://opensea.io/rankings"
res <- read_html(URL)

pattern <- "#__NEXT_DATA__"
D <- res %>% 
  html_nodes(pattern) %>% 
  html_text()

library(jsonlite)
data <- fromJSON(D)

# 콜렉션 이름, 거래량, 바닥가격 등 정보 가져오기

collection <- data$props$relayCache[[1]][[2]]$data$rankings$edges$node$name
volume <- data$props$relayCache[[1]][[2]]$data$rankings$edges$node$statsV2$sevenDayVolume$unit %>% 
  as.numeric() %>% 
  round(digit=2)# 7dlfrk
fp_unit <- data$props$relayCache[[1]][[2]]$data$rankings$edges$node$statsV2$floorPrice$unit %>%
  as.numeric() %>% 
  round(digit=2)
native <-  data$props$relayCache[[1]][[2]]$data$rankings$edges$node$nativePaymentAsset$symbol
fp_eth <- data$props$relayCache[[1]][[2]]$data$rankings$edges$node$statsV2$floorPrice$eth %>%
  as.numeric() %>% 
  round(digit=2)
id_url <- data$props$relayCache[[1]][[2]]$data$rankings$edges$node$slug
url <- str_c("https://opensea.io/collection/", id_url)
rankings <- row.names(data$props$relayCache[[1]][[2]]$data$rankings$edges$node$nativePaymentAsset)

tab <- data.frame(cbind(rankings, collection, volume, fp_unit, native, fp_eth, url))
view(tab)

library(writexl)
write_xlsx(tab,"OpenSea 랭킹.xlsx")

# 암호화폐(코인마켓캡) - API 이용

library(dotenv)
load_dot_env(".bash_profile")

api_key <- Sys.getenv("COINCAP_API")

api <- "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"

url <- str_c(api,"?CMC_PRO_API_KEY=", api_key, "&convert=KRW")
res <- fromJSON(url)

# 상위 100개 코인 이름 및 USD
df.json <- res$data
tab <- data.frame(cbind(df.json$name, df.json$symbol, df.json$quote$KRW$price))
tab$X3 <- tab$X3 %>%
  as.numeric() %>% 
  round()

names(tab) <- c("name","ticker","price(KRW)")
write_xlsx(tab,"크립토 랭킹.xlsx")
