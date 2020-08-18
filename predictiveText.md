Predictive Text Modeling
========================

Overview
--------

The main objective of this project is to build a predictive text
model.The predictive texting consists of a data processed tool that
makes it quicker and easier to write text by suggesting words as you
type, predictive text can significantly speed up the input process.

In this file a large corpus of text documents is analized to discover
the structure in the data and how words are put together in order to
create a model of predctions using N-grams. It is shown how is loaded,
cleaned, sampled and analized the data provided by Swiftkey from:

-   <a href="https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip" class="uri">https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip</a>

Data import and sampling
========================

``` r
suppressPackageStartupMessages(library(dplyr))
library(tidytext)
library(stringi)
suppressPackageStartupMessages(library(tm))
library(RWeka)
suppressPackageStartupMessages(library(wordcloud))
suppressPackageStartupMessages(library(ggplot2))
```

The data is loaded according to the saved path of the files, in this
case in “final” folder. The News dataset is needed to be loaded in
binary mode (“rb”).

``` r
blogs <- readLines("final/en_US/en_US.blogs.txt", warn = F)
twitter <- readLines("final/en_US/en_US.twitter.txt", warn = F)
```

``` r
con <- file("final/en_US/en_US.news.txt", open="rb")
news <- readLines(con, encoding="UTF-8")
close(con)
rm(con)
```

First, we estimate size of loaded variables. The results below show that
every dataset is over 250 Mb or even higher.

``` r
blogsSize<-object.size(blogs)
twitterSize<-object.size(twitter)
newsSize<-object.size(news)
```

``` r
print(blogsSize, units = "Mb")  
```

    ## 255.4 Mb

``` r
print(twitterSize, units = "Mb")  
```

    ## 319 Mb

``` r
print(newsSize, units = "Mb")  
```

    ## 257.3 Mb

A word count is performed for every row of the files and then added in
order to create a histogram of word count in millions of words contained
in each file loaded.

``` r
blogsRowCount<-stri_count_words(blogs)
twitterRowCount<-stri_count_words(twitter)
newsRowCount<-stri_count_words(news)

blogsCount <- sum(blogsRowCount)
twitterCount <- sum(twitterRowCount)
newsCount <- sum(newsRowCount)

totalCount <- c(Blogs = blogsCount, Twitter = twitterCount, News = newsCount)*(1/1e6)
barplot(height = totalCount, xlab = "File", ylab = "Milions of words", main = "Number of words in each file", col=rgb(0.2,0.4,0.6,0.6))
```

![](predictiveText_files/figure-markdown_github/unnamed-chunk-8-1.png)
So we have over 30 million words in each file. The exact amount of words
contained in each file is shown below:

``` r
totalCount
```

    ##    Blogs  Twitter     News 
    ## 38.15424 30.21812 34.76239

A summary is displayed for the variation of word counts in each row for
every file loaded. As we see, most of the rows contain a few words, less
than 50 words, but there are lines with thousands of words in a single
row. Also, there are a few other that do not contain any word.

``` r
summary(blogsRowCount)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00    9.00   29.00   42.43   61.00 6726.00

``` r
summary(twitterRowCount)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##     1.0     7.0    12.0    12.8    18.0    60.0

``` r
summary(newsRowCount)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##    0.00   19.00   32.00   34.41   46.00 1796.00

Data Sampling
-------------

We first stablish a seed for reproducible purposes and a percentage of
reference for the sampling of the data.

``` r
set.seed(200)
```

``` r
percentage<-0.01
```

The sampling made is as shown in the next cell where a vector from 1 to
100 is sampled randomly, getting only the 10% of the data.

``` r
sample(c(1:100), size=100*0.1, replace =FALSE)
```

    ##  [1] 54 58 99 68 65 80 67  9 49 22

For speed reasons in the building process, only 1% of the total dataset
was sampled. The same process as the cell before is applied for the
blogs, news and twitter dataset:

``` r
blogs <- blogs[sample(c(1:length(blogs)), size=length(blogs)*percentage,
                      replace=FALSE)]

news <- news[sample(c(1:length(news)), size=length(news)*percentage, 
                    replace =FALSE)]

twitter <- twitter[sample(c(1:length(twitter)), size=length(twitter)*percentage,
                          replace =FALSE)]
```

Afeter that, the sampled data is saved a specific folder for later
analysis

``` r
write.csv(blogs, file = "Sample/blogSample.csv", row.names = FALSE, 
          col.names = FALSE)
```

    ## Warning in write.csv(blogs, file = "Sample/blogSample.csv", row.names = FALSE, :
    ## attempt to set 'col.names' ignored

``` r
write.csv(news, file = "Sample/newsSample.csv", row.names = FALSE, 
          col.names = FALSE)
```

    ## Warning in write.csv(news, file = "Sample/newsSample.csv", row.names = FALSE, :
    ## attempt to set 'col.names' ignored

``` r
write.csv(twitter, file = "Sample/twitterSample.csv", row.names = FALSE,
          col.names = FALSE)
```

    ## Warning in write.csv(twitter, file = "Sample/twitterSample.csv", row.names =
    ## FALSE, : attempt to set 'col.names' ignored

Unnecesay variables are removed for workspace cleaning and memory
optimization.

``` r
rm(blogsCount,blogsRowCount, blogsSize, newsCount, newsRowCount, newsSize,
   twitterCount, twitterRowCount, twitterSize, percentage, totalCount, 
   blogs, news, twitter)
```

Data cleaning
-------------

Once again, the data is loaded but only the sampled files obtained
before and combined into a corpus. Transforming data into “Large Simple
Corpus” type in order to make tm\_map transformations possible

``` r
corpus <-Corpus(DirSource("Sample/"), readerControl = list(language="en_US"))
```

From the corpus, numbers, punctuation, and leading and/or trailing
whitespace is removed. Also, every string element is transformed to
lower case.

``` r
corpus<-tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, tolower)
```

A special function is created for removing special characters on the
corpus.

``` r
onlyLetters <- function(x)
          gsub("[^A-Za-z///' ]","" , x ,ignore.case = TRUE)
corpus <- tm_map(corpus, onlyLetters)
```

For removing bad words, a dirty, naughty and obscene bad words list was
downloaded to remove those from the corpus. The original list can be
found in:

-   <a href="https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words" class="uri">https://github.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words</a>

For the purpose of this project, only the english version (“en”) was
used.

``` r
badwords <- read.csv("en")
badwords <- badwords$X2g1c
corpus <- tm_map(corpus, removeWords, badwords)
```

Stop words are not removed beacuse that could be the case that those
words were the expected prediction

N-Grams analysis
================

One of the most effective ways to explore the relationship between words
is using N-gram models, in other words, examining which words tend to
follow others immediately. This can be done by the frequency of times
that a word was followed by another (bigram model), the number of times
that a word was followed by two other words (trigram model) and so on.
For code saving and for readability, a create “n” gram function model
was created.

``` r
calcNgramModel <- function(mycorpus, N){
  token_delim <- " \\t\\r\\n.!?,;\"()"
  token <- NGramTokenizer(mycorpus, Weka_control(min=N,max=N, 
                                                   delimiters = token_delim))
  data <- data.frame(table(token))
  sort_data <- data[order(data$Freq,decreasing=TRUE),]
  sort_data
}
```

The function was used for creating the desired model by passing the
recently clened dataset (corpus) and “n” which is the ngram model
expected (number of analysed consecutive words). Also, a histogram of
the 20 most frequent ngrams and a wordcloud is displayed. This process
is repeated for the unigram, bigram and trigram model.

``` r
unigramModel <- calcNgramModel(corpus, 1)
head(unigramModel)
```

    ##       token  Freq
    ## 50098   the 47542
    ## 50880    to 27556
    ## 2         a 24020
    ## 1705    and 23991
    ## 34781    of 19894
    ## 23887     i 16495

``` r
ggplot(data=unigramModel[1:20,], aes(x=reorder(token,Freq), y=Freq)) +
  geom_bar(stat="identity",fill=rgb(0.2,0.4,0.6,0.6), colour="black") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + coord_flip() +
  ggtitle("Unigram Model")
```

![](predictiveText_files/figure-markdown_github/unnamed-chunk-25-1.png)

``` r
wordcloud(unigramModel$token,unigramModel$Freq,random.order=FALSE,scale = 
            c(2,0.35),min.freq = 500,
          colors = brewer.pal(8,"Dark2"),max.words=150)
```

![](predictiveText_files/figure-markdown_github/unnamed-chunk-26-1.png)

``` r
bigramModel <- calcNgramModel(corpus, 2)
head(bigramModel)
```

    ##          token Freq
    ## 278358  of the 4357
    ## 197678  in the 4087
    ## 416213  to the 2167
    ## 148648 for the 1999
    ## 283395  on the 1941
    ## 412633   to be 1622

``` r
ggplot(data=bigramModel[1:20,], aes(x=reorder(token,Freq), y=Freq)) +
  geom_bar(stat="identity",fill=rgb(0.2,0.4,0.6,0.6), colour="black") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + coord_flip() +
  ggtitle("Bigram Model")
```

![](predictiveText_files/figure-markdown_github/unnamed-chunk-28-1.png)

``` r
wordcloud(bigramModel$token,bigramModel$Freq,random.order=FALSE,scale = 
            c(2,0.35),min.freq = 500,
          colors = brewer.pal(8,"Dark2"),max.words=150)
```

![](predictiveText_files/figure-markdown_github/unnamed-chunk-29-1.png)

``` r
trigramModel <- calcNgramModel(corpus,3)
head(trigramModel)
```

    ##                 token Freq
    ## 505492     one of the  341
    ## 9284         a lot of  291
    ## 656917 thanks for the  256
    ## 729670        to be a  183
    ## 675837     the end of  166
    ## 273250    going to be  159

``` r
ggplot(data=trigramModel[1:20,], aes(x=reorder(token,Freq), y=Freq)) +
  geom_bar(stat="identity",fill=rgb(0.2,0.4,0.6,0.6), colour="black") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) + coord_flip() +
  ggtitle("Trigram Model")
```

![](predictiveText_files/figure-markdown_github/unnamed-chunk-31-1.png)

``` r
wordcloud(trigramModel$token,trigramModel$Freq,random.order=FALSE,scale = 
            c(2,0.35),min.freq = 50,
          colors = brewer.pal(8,"Dark2"),max.words=150)
```

![](predictiveText_files/figure-markdown_github/unnamed-chunk-32-1.png)

The result is a frequency table of the most common consecutive words in
english for 1,2,3 consecutive words. For the next word predictions this
could be used as if the reference, selecting the “n”-gram model and
searching for “n-1” words, we’ll be able to predict the next word.
