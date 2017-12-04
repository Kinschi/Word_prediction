library(ANLP)
library(quanteda)

## 1. Creation of data for prediction function

# Reading in raw data 
folder <- "./Coursera-SwiftKey/final/en_US/"

blogs_file <- paste(folder, "en_US.blogs.txt", sep = "")
twitter_file <- paste(folder, "en_US.twitter.txt", sep = "")
news_file <- paste(folder, "en_US.news.txt", sep = "")

rm(folder)

if (!file.exists(blogs_file) |
    !file.exists(twitter_file) |
    !file.exists(news_file)) {
  zipfile <- "./Coursera-SwiftKey.zip"
  if (!file.exists(zipfile)) {
    url <- download.file("http://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip",destfile = zipfile, mode = "wb")
  }
  unzip(zipfile, exdir = "./Coursera-SwiftKey")
  rm(zipfile)
}

bfile <- file(blogs_file, open = "rb")
blogs <- readLines(bfile, encoding= "UTF-8", warn = FALSE, skipNul = TRUE)
close(bfile)
rm(bfile, blogs_file)

tfile <- file(twitter_file, open = "rb")
twitter <- readLines(tfile, encoding= "UTF-8", warn = FALSE, skipNul = TRUE)
close(tfile)
rm(tfile, twitter_file)

nfile <- file(news_file, open = "rb")
news <- readLines(nfile, encoding= "UTF-8", warn = FALSE, skipNul = TRUE)
close(nfile)
rm(nfile, news_file)

blogs <- iconv(blogs, from = "UTF-8", to = "ASCII", sub = "")
twitter <- iconv(twitter, from = "UTF-8", to = "ASCII", sub = "")
news <- iconv(news, from = "UTF-8", to = "ASCII", sub = "")

# Data sampling
set.seed(1)
data.sample <- c(blogs, twitter, news)
data.sample <- c(sample(blogs, length(blogs) * 0.2, replace = FALSE),
                 sample(news, length(news) * 0.2, replace = FALSE),
                 sample(twitter, length(twitter) * 0.2, replace = FALSE))

rm(blogs, news, twitter)

# Increasing memory
options(java.parameters = "-Xmx5g")

# N-gram tokenization - creating unigrams, bigrams, trigrams, quadgrams und fivegrams
df1 <- dfm(data.sample, verbose = TRUE, tolower = TRUE,
           remove_numbers = TRUE, remove_punct = TRUE, remove_separators = 
             TRUE, remove_twitter = TRUE, stem = FALSE,thesaurus = NULL,
           dictionary = NULL, valuetype = c("glob", "regex", "fixed"))

df1 <- data.frame(word = features(df1), freq = colSums(df1), row.names = NULL, stringsAsFactors = FALSE)
df1$freq <- sort(df1$freq, decreasing = T)
df1 <- subset(df1,df1$freq > 100)
df1 <- subset(df1, df1$word != "")
saveRDS(df1,file = "df1.RDS")

df2 <- dfm(data.sample, ngrams=2, concatenator = " ",
           what = "fastestword", 
           verbose = FALSE, tolower = TRUE,
           remove_numbers = TRUE, remove_punct = TRUE, remove_separators = 
             TRUE, remove_twitter = TRUE,
           stem = FALSE, thesaurus = NULL, 
           dictionary = NULL, valuetype = "fixed")

df2 <- data.frame(word = features(df2), freq = colSums(df2), row.names = NULL, stringsAsFactors = FALSE)
df2$freq <- sort(df2$freq, decreasing = T)
df2 <- subset(df2,df2$freq > 5)
df2 <- subset(df2, df2$word != "")
saveRDS(df2,file = "df2.RDS")

df3 <- dfm(data.sample, ngrams=3, concatenator = " ",
           what = "fastestword",
           verbose = FALSE, tolower = TRUE,
           remove_numbers = TRUE, remove_punct = TRUE, remove_separators = 
             TRUE,
           remove_twitter = TRUE, stem = FALSE, thesaurus = NULL, 
           dictionary = NULL, valuetype = "fixed")

df3 <- data.frame(word = features(df3), freq = colSums(df3), row.names = NULL, stringsAsFactors = FALSE)
df3$freq <- sort(df3$freq, decreasing = T)
df3 <- subset(df3,df3$freq > 2)
df3 <- subset(df3, df3$word != "")
saveRDS(df3,file = "df3.RDS")

df4 <- dfm(data.sample, ngrams=4, concatenator = " ",
           what = "fastestword",
           verbose = FALSE, tolower = TRUE,
           remove_numbers = TRUE, remove_punct = TRUE, remove_separators = 
             TRUE, remove_twitter = TRUE, stem = FALSE, thesaurus = NULL, 
           dictionary = NULL, valuetype = "fixed")

df4 <- data.frame(word = features(df4), freq = colSums(df4), row.names = NULL, stringsAsFactors = FALSE)
df4$freq <- sort(df4$freq, decreasing = T)
df4 <- subset(df4,df4$freq > 2)
df4 <- subset(df4, df4$word != "")
saveRDS(df4,file = "df4.RDS")

df5 <- dfm(data.sample, ngrams=5, concatenator = " ",
           what = "fastestword",
           verbose = FALSE, tolower = TRUE,
           remove_numbers = TRUE, remove_punct = TRUE, remove_separators = 
             TRUE,
           remove_twitter = TRUE, stem = FALSE, thesaurus = NULL, 
           dictionary = NULL, valuetype = "fixed")

df5 <- data.frame(word = features(df5), freq = colSums(df5), row.names = NULL, stringsAsFactors = FALSE)
df5$freq <- sort(df5$freq, decreasing = T)
df5 <- subset(df5,df5$freq > 1)
df5 <- subset(df5, df5$word != "")
saveRDS(df5,file = "df5.RDS")

rm(data.sample)

# Creating and saving a large list consisting of 5 S3-dataframes (unigrams, bigrams, trigrams, quadgrams, fivegrams)
#df1 <- readRDS("df1.RDS")
#df2 <- readRDS("df2.RDS")
#df3 <- readRDS("df3.RDS")
#df4 <- readRDS("df4.RDS")
#df5 <- readRDS("df5.RDS")

ngrams <- list(df5, df4, df3, df2, df1)
saveRDS(ngrams,file = "ngrams.RDS")

rm(df5, df4, df3, df2, df1, ngrams)


## 2. Simple backoff prediction function

ngrams <- readRDS("ngrams.RDS")

# Examples - prediction
predict_Backoff("I want", ngrams) #expected outcome possibilities: to / is / a / the / you
