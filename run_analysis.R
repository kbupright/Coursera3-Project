## This script will download the UCI HAR Dataset from, unzip it, read the
## training and test files and merge them into a single tidy data set with 
## averages of the variables associated with the mean and standard deviation.
## It will write this dataset to a file called 'tidyset.txt'

## this script requires the use of the plyr and dplyr packages

## library (plyr)
## library(dplyr)

## check to see if directory exists, otherwise create it

if (!file.exists("data")) {
        dir.create("data")
}

## download UCI HAR dataset zip file 
fileUrl <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/UCIHAR.zip")
dateDownloaded <- date()

## unzip the file to the same director
unzip("./data/UCIHAR.zip", exdir = "./data")

## read the needed files in from the unzipped file
## note:  note all files are needed for this exercise
xtrain <- read.table("./data/UCI HAR Dataset/train/x_train.txt")
ytrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
xtest <- read.table("./data/UCI HAR Dataset/test/x_test.txt")
ytest <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
features <- read.table("./data/UCI HAR Dataset/features.txt")
subtrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
subtest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

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

# Bind subject and action to data set and combine to a single set
# cast subject as a factor
xtest <- cbind(subtest, ytest, xtest)
xtrain <- cbind(subtrain, ytrain, xtrain)
data <- rbind(xtest, xtrain)
data <- arrange(data, subject, activity)
data$subject <- as.factor(data$subject)

## update column names to include time and freq notation for readability
# and remove the extraneous '()'
t <- substring(names(data), 1, 1) == "t"
f <- substring(names(data), 1, 1) == "f"
colnames(data)[t] <- sub("t", "AvgTime", names(data)[t])
colnames(data)[f] <- sub("f", "AvgFreq", names(data)[f])
colnames(data) <- gsub("\\()", "", names(data))

# update the 'activity' to have the matching label[2]
data <- mutate(data, activity = labels[activity, 2])

# group by subject and activity
data <- group_by(data, subject, activity)
# calculate the mean for each group
data <- summarise_each(data, funs(mean))

# write table to 'tidyset'
write.table(data, file = "./data/tidyset.txt", row.names = FALSE)