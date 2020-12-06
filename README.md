# README

## Extracting the data

Raw data is obtained from <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip> and unzipped in the working directory

## Reading the data

We first read in the activity labels and feature names. read.table with HEADER false is chosen as the column will be manually named later as we are only interested in the data

```{r}
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
features_colnum <- read.table("UCI HAR Dataset/features.txt", header = FALSE)
```

The complete train data is created by combining the test data and train data. We first read in the files from both sets of data

### Test data

```{r}
activity_test <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
features_test <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
```

### Train data

```{r}
activity_train <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
features_train<- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
```

## Naming the variables

Data is categorized into 3 parts (activity,subject,features) and are later named. Names for the features data are obtained from features_colnum

```{r}
activity <- rbind(activity_train, activity_test)
colnames(activity) <- "Activity"
subject <- rbind(subject_train, subject_test)
colnames(subject) <- "Subject"
features <- rbind(features_train, features_test)
colnames(features) <- t(features_colnum[,2])
```

## Merge Data

Merge all 3 parts together with cbind

```{r}
Data <- cbind(activity,subject,features)
```

## Create data with only mean and standard deviation measurements

Once the complete data is created, we need to extract only the measurements on the mean and standard deviation for each feature. The following code will extract the col num where the word Mean() or Std() is found in column names

```{r}
colnum_MeanSTD <- grep(".*Mean()|.*Std()", names(Data), ignore.case=TRUE)
```

Then we can subset the needed column only. This forms the data set where mean and std are the only measurements

```{r}
MeanStd_Data <- Data[,c(1,2,colnum_MeanSTD)]
```

## Naming the activities

Activity numbers are replaced with activity name from activity_labels by using a for loop.

```{r}
MeanStd_Data$Activity <- as.character(MeanStd_Data$Activity)
for (i in 1:6){
  MeanStd_Data$Activity[MeanStd_Data$Activity == i] <- as.character(activity_labels[i,2])
}
```

## Creating tiny data

Preparing tiny data with average of each variable for each activity and each subject

```{r}
tidy <- group_by(MeanStd_Data, Subject, Activity)
tidy_mean <- summarise_each(tidy, funs(mean))
```
## Apply descriptive variable names 

Applying descriptive variable names for time and frequency

```{r}
colnames(tidy_mean) <- gsub(pattern="^t" , replacement="time", colnames(tidy))
colnames(tidy_mean) <- gsub(pattern="^f" , replacement="freq", colnames(tidy))
}
```

## Writing data

Write data as Tiny.txt

```{r}
write.table(tidy_mean, "Tidy.txt", row.names=FALSE, quote=FALSE)
```

