---
title: "Coursera 3 - Course Project"
author: "K.B. Upright"
date: "Saturday, July 25, 2015"
output: html_document
---

## Introduction

The R script "run_analysis.R" reuqires the plyr and dplyr packages.  Please install these before continuing.

This R script downloads a file from this location:  http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#. [1] It processes the files in the zip file and produces a tidy data set that averages the means and standard deviations of observations by subject and activity.

Details on files used and variables produced can be found in the accompanying codebook.

## Steps

This R script will check for a directory, and create one if it does not exist.

```{r}
## check to see if directory exists, otherwise create it
if (!file.exists("data")) {
        dir.create("data")
}
```

The script downloads the file, unzips it and reads the tables it needs from the directory.

```{r}
## download UCI HAR dataset zip file 
fileUrl <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/UCIHAR.zip")
dateDownloaded <- date()

## unzip the file to the same directory
unzip("./data/UCIHAR.zip", exdir = "./data")

## read the needed files in from the unzipped file
## note:  not all files are needed for this exercise
xtrain <- read.table("./data/UCI HAR Dataset/train/x_train.txt")
ytrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
xtest <- read.table("./data/UCI HAR Dataset/test/x_test.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
features <- read.table("./data/UCI HAR Dataset/features.txt")
subtrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
subtest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
```

It then sets appropriate column names and removes any columns that are not associated with the mean and standard deviation.

```{r}
## set column names
# features file contains the column names. these will be cast as character
features <- features[2]
features[] <- lapply(features, as.character)

# set the column names in each file
colnames(xtest) <- features[[1]]
colnames(xtrain) <- features[[1]]
colnames(subtest) <- c('subject')
colnames(subtrain) <- c('subject')
colnames(ytest) <- c('activity')
colnames(ytrain) <- c('activity')

# remove columns not associated with standard deviation or mean
colList <- setdiff(grep("std|mean", features[[1]]), 
                   grep("meanFreq", features[[1]]))
xtest <- xtest[, colList]
xtrain <- xtrain[, colList]
```

As the subjects were originally divided into test and training groups, it combines these two groups and then renames variables in preparation for the final tidy data set.  The data is arranged by subject and activity and the subject variable is cast to a factor.

```{r}
# Bind subject and action to data set and combine to a single set
# cast subject as a factor
xtest <- cbind(subtest, ytest, xtest)
xtrain <- cbind(subtrain, ytrain, xtrain)
data <- rbind(xtest, xtrain)
data <- arrange(data, subject, activity)
data$subject <- as.factor(data$subject)
```

Column names are updated to be more descriptive.  Details on each variable can be found in the accompanying code book.
.
```{r}
## update column names to include time and freq notation for readability
# and remove the extraneous '()'
t <- substring(names(data), 1, 1) == "t"
f <- substring(names(data), 1, 1) == "f"
colnames(data)[t] <- sub("t", "AvgTime", names(data)[t])
colnames(data)[f] <- sub("f", "AvgFreq", names(data)[f])
colnames(data) <- gsub("\\()", "", names(data))

# update the 'activity' to have the matching label[2]
data <- mutate(data, activity = labels[activity, 2])

```

The data is grouped by subject and activity and then the data in each grouping is summarized by mean.

```{r}
# group by subject and activity
data <- group_by(data, subject, activity)
# calculate the mean for each group
data <- summarise_each(data, funs(mean))
```

Finally. the data is written to a table called "tidydata.txt" in the same directory.

```{r}
# write table to 'tidyset'
write.table(data, file = "./data/tidyset.txt", row.names = FALSE)
```


==========

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

