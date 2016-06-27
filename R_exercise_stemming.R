# R_exercise_stemming.R
#
# Purpose:  Stemming (and lemmatization)
#
# Version: 0.2
#
# Date:    2016  06  26
# Authors: Boris Steipe (boris.steipe@utoronto.ca)
#          Yi Chen (yi.chen@aesthetics.mpg.de)
#
# V 0.2    Add stemming with tm, then add lemmatization based on the
#          Morphy dictionary.
# V 0.1    First code with SnowballC
#
# TODO:
#
#
# ====================================================================



# ====================================================================
#        PART ONE: INSTALL SnowballC
# ====================================================================

# install the package only if you have not installed it previously
install.packages("SnowballC")
library(SnowballC)

# try it
getStemLanguages()

myWords <- c("spiele", "spielst", "spielt", "spielen", "spielt", "spielen")

wordStem(myWords, language = "de")

# Hm. Not impressed ...

# lets look at the supplied vocabulary ...
load(system.file("words", "german.RData", package = "SnowballC"))

# lots of nonsense - why?
# Look at the German stemming algorithm:
# http://snowball.tartarus.org/algorithms/german/stemmer.html

# Tentatively it seems that a base-form is being defined that is not stemmed.
# I am sceptical of that approach. Let's see what the stemming function of
# the tm package does ...


# ====================================================================
#        PART TWO: INSTALL tm
# ====================================================================

# install the package only if you have not installed it previously
install.packages("tm")
library(tm)

# In tm, actions are called "transformations" that are applied to text (a
# corpus). Let's see what transformations are available:

getTransformations()

# one of these is stemDocument. stemDocument feeds words to SnowballC and
# collates the stems. Internally it uses exactly the same wordStem() function
# that we have explored above.

# The standard workflow is well explained in the accompanying documentation:
# https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf

testTm <- VCorpus(VectorSource("spiele spielst spielt spielen spielt spielen"),
                  readerControl = list(language = "deu"))
inspect(testTm)
meta(testTm, "language")
as.character(testTm[[1]])
stemTest <- tm_map(testTm, stemDocument)
as.character(stemTest[[1]])

# That's the same result that we got above with SnowballC. Not surprising.

stemCompletion("spiel", testTm)   # "spiele"
stemCompletion("spielt", testTm)  # "spielt"

# This demonstrates that in fact the German stemming algorithm is at the root of
# the problem. stemCompletion() does not normalize to the same word.  :-(

# Conceptually, the stemming algorithm is not perfect. It can remove some
# inconsistencies in word-frequencies. For improved performance we have to
# employ lemmatization.


# ====================================================================
#        PART THREE: Lemmatization
# ====================================================================

# The German lemmatizer "Morphy" has been available on Windows since the 1990s.
# Its source dictionary can be downloaded from
# http://www.danielnaber.de/morphologie/ under a CC license (attribution).
# Download the ".csv" file (its actually tab-separated ...), unzip it and put it
# into a directory above the working directory - cf. the path below.

morphyDict <- read.csv("../data/morphy/morphy-mapping-20110717.csv",
                       sep = "\t",
                       skip = 15,
                       header = FALSE,
                       stringsAsFactors = FALSE)
head(morphyDict)

# This is a pretty big table and it would not be very efficient to look for
# every single token in our corpus. But we don't have to! We can use it to
# lemmatize only the stemCompleted() forms. There is a problem however in that
# the lower case forms of the dictionary entries are not unique - I'm not
# entirely sure why there are uppercase forms - i.e. exactly when a nominalized
# verb would need to remain in the nominal form. However, we need the entries to
# be unique for lookup. Therefore we split the dictionary into a noun and a verb
# part, drop all duplicated tokens and make a single-column dataframe with the
# token forms as rownames:

nouns <- grep("^[A-ZÄÖÜ]", morphyDict$V1)

tmp <- morphyDict[ - nouns, ]
tmp <- tmp[! duplicated(tmp[ , 1]), ]
myDict  <- data.frame(tmp[ , 2], stringsAsFactors = FALSE)
rownames(myDict)  <- tmp[ , 1]

tmp <- morphyDict[ nouns, ]
tmp <- tmp[! duplicated(tmp[ , 1]), ]
myDictN  <- data.frame(tmp[ , 2], stringsAsFactors = FALSE)
rownames(myDictN)  <- tmp[ , 1]

rm(tmp)

# Now the lemmatized forms can be looked up efficiently ...

myDict["spiele", 1]  # spielen
myDict["spielt", 1]  # spielen

myDictN["Spiele", 1] # Spiel

# This also works ...
myDict[myWords, 1]

# ... but the lemmata themselves are not present in this case: i.e. if a word is
# not present - lookup returns NA - then just leave it as is. We could fix this
# if we care.

# Caution: the returned lemma is not always the absolute base form. One needs to
# always check whether it can be further reduced.
#
# Caution: German split-verbs are not properly treated here (Ich spiele mit ->
# mitspielen). This would require much more sophisticated processing.


# [END]
