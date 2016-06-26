# R_exercise_stemming.R
#
# Purpose:  Stemming with SnowballC
#
# Version: 0.1
#
# Date:    2016  06  26
# Authors: Boris Steipe (boris.steipe@utoronto.ca)
#          Yi Chen (yi.chen@aesthetics.mpg.de)
#
# V 0.1    First code
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

# ...

# == SECTION =========================================================


# == Subsection

# Continue ...








# ====================================================================
#        APPENDIX: OUTLOOK
# ====================================================================




# [END]
