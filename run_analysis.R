library(data.table)
library(dplyr)

# We first read in the activity labels and feature names. read.table with HEADER 
# false is chosen as the column will be manually named later and we are only 
# interested in the data

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
features_colnum <- read.table("UCI HAR Dataset/features.txt", header = FALSE)

# The complete train data is created by combining the test data and train data
# We first read in the files from both sets of data

# Read in test data
activity_test <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
features_test <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)

# Read in train data
activity_train <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
features_train<- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)

# Data is categorized into 3 parts (activity,subject,features) and are later 
# named. Names for the features data are obtained from features_colnum

activity <- rbind(activity_train, activity_test)
colnames(activity) <- "Activity"
subject <- rbind(subject_train, subject_test)
colnames(subject) <- "Subject"
features <- rbind(features_train, features_test)
colnames(features) <- t(features_colnum[,2])

# Merge all 3 parts together with cbind

Data <- cbind(activity,subject,features)

# Once the complete data is created, we need to extract only the measurements
# on the mean and standard deviation for each feature. The following code will 
# extract the col num where the word Mean() or Std() is found in column names

colnum_MeanSTD <- grep(".*Mean()|.*Std()", names(Data), ignore.case=TRUE)

# Then we can subset the needed column only. This forms the data set where 
# mean and std are the only measurements

MeanStd_Data <- Data[,c(1,2,colnum_MeanSTD)]

# Naming the activities

MeanStd_Data$Activity <- as.character(MeanStd_Data$Activity)
for (i in 1:6){
  MeanStd_Data$Activity[MeanStd_Data$Activity == i] <- as.character(activity_labels[i,2])
}

# Preparing tiny data with average of each variable for each activity and 
# each subject

tidy <- group_by(MeanStd_Data, Subject, Activity)
tidy_mean <- summarise_each(tidy, funs(mean))

# Applying descriptive variable names for time and frequency

colnames(tidy_mean) <- gsub(pattern="^t" , replacement="time", colnames(tidy))
colnames(tidy_mean) <- gsub(pattern="^f" , replacement="freq", colnames(tidy))

# write data as Tidy.txt

write.table(tidy_mean, "Tidy.txt", row.names=FALSE, quote=FALSE)


