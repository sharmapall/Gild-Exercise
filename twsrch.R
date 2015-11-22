library(twitteR)
library(RCurl)
library(RJSONIO)
library(stringr)
library(ROAuth)
library(streamR)
library(tm)
library(wordcloud)
library(RColorBrewer)


requestURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"
consumerKey <- "8OBJbZbmni1F8hdhupBqCFicP"
consumerSecret <- "TutsxPaLFnHwLIX2ObKGzG3yNSuCdJmAFuosVt5tPedCmmdn5E"
my_oauth <- OAuthFactory$new(consumerKey = consumerKey, consumerSecret = consumerSecret, 
                             requestURL = requestURL, accessURL = accessURL, authURL = authURL)
my_oauth$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))
save(my_oauth, file = "my_oauth.Rdata")

access_token<-	"4257967572-nqMCNBP6DdI3YANieATk9c0v7NQSaIrX4kJPQOe"
access_token_secret<-	"cEwkVuZhnCcuHTCd8MMz6BA7PWlX4eiov7UUGAkt41uxY"


setup_twitter_oauth(consumerKey, consumerSecret,access_token,access_token_secret)

first<- "america"
second<- "france"
srch<- paste(first,"+",second)

fr<-searchTwitter(srch, lang= "en", n=3000, resultType = "recent")
fr<-strip_retweets(fr, strip_manual = TRUE, strip_mt = TRUE)
fr_text<-sapply(fr, function(x) x$getText() )
frcorpus <- Corpus(VectorSource(fr_text))

frcorpus <- tm_map(frcorpus,
                   content_transformer(function(x) iconv(x, to='UTF-8-MAC', sub='byte')),
                   mc.cores=1)


frclean <-tm_map(frcorpus, removePunctuation)
frclean<- tm_map(frclean, content_transformer(tolower))
frclean<- tm_map(frclean, removeWords, stopwords("english"))
frclean<- tm_map(frclean, removeNumbers)
frclean<- tm_map(frclean, stripWhitespace)
frclean<- tm_map(frclean, removeWords, c(first, second, "amp", "will", "via", "like"))


wordcloud(frclean, random.order = F, max.words = 50, min.freq = 40, colors=brewer.pal(6, "Dark2") )







# load("my_oauth.Rdata")
# filterStream(file.name = "tweets.json", # Save tweets in a json file
#              track = c("Syria", "ISIS", "Paris"), # Collect tweets mentioning either Affordable Care Act, ACA, or Obamacare
#              language = "en",
#              timeout = 60, # Keep connection alive for 60 seconds
#              oauth = my_oauth) # Use my_oauth file as the OAuth credentials
# paristweet.df <- parseTweets("tweets.json", simplify = FALSE) # parse the json file and save to a data frame called tweets.df. 
# 
# samp <- paristweet.df["text"]
# sampcorpus <- tm_map(sampcorpus,
#                    content_transformer(function(x) iconv(x, to='UTF-8-MAC', sub='byte')),
#                    mc.cores=1)
# #sampcorpus <- Corpus(VectorSource(samp))
# sampclean <-tm_map(sampcorpus, removePunctuation)
# sampclean<- tm_map(sampclean, content_transformer(tolower))
# sampclean<- tm_map(sampclean, removeWords, stopwords("english"))
# sampclean<- tm_map(sampclean, removeNumbers)
# sampclean<- tm_map(sampclean, stripWhitespace)
# wordcloud(sampclean, random.order = F, max.words = 100, col= rainbow(50) )


# 
# myDTM = TermDocumentMatrix(frcorpus, control = list(minWordLength = 1))
# m = as.matrix(myDTM)
# v = sort(rowSums(m), decreasing = TRUE)
