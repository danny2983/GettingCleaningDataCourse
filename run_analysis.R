#******************************************************************
#Step 1.Merges the training and the test sets to create one data set.
#******************************************************************

#Downloading and extract 

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#Reading files

# trainings tables:

x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# testing tables:
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Reading feature vector:
features <- read.table('./data/UCI HAR Dataset/features.txt')

# Reading activity labels:
activity_labels = read.table('./data/UCI HAR Dataset/activity_labels.txt')

# Assigning column names:

colnames(x_train) <- features[,2]
colnames(y_train) <-"activityId"
colnames(subject_train) <- "subjectId"

colnames(x_test) <- features[,2] 
colnames(y_test) <- "activityId"
colnames(subject_test) <- "subjectId"

colnames(activity_labels) <- c('activityId','activityType')

#Merging data:

train_merged <- cbind(y_train, subject_train, x_train)
test_merged <- cbind(y_test, subject_test, x_test)
mergedTestTrain <- rbind(train_merged, test_merged)

#******************************************************************
#Step 2.-Extracts only the measurements on the mean and standard deviation for each measurement.
#******************************************************************

columnsTeTr <- colnames(mergedTestTrain)

#vector for defining ID, mean and standard deviation:

mean_and_std <- (grepl("activityId" , columnsTeTr) | 
                   grepl("subjectId" , columnsTeTr) | 
                   grepl("mean.." , columnsTeTr) | 
                   grepl("std.." , columnsTeTr) 
)

# subset from mergedTestTrain:

MeanStdDevTeTr <- mergedTestTrain[ , mean_and_std == TRUE]

#******************************************************************
#Step 3. Uses descriptive activity names to name the activities in the data set
#******************************************************************

activityNames <- merge(MeanStdDevTeTr, activity_labels,
                              by='activityId',
                              all.x=TRUE)

#******************************************************************
#Step 4. Appropriately labels the data set with descriptive variable names.
#******************************************************************

names(activityNames)<-gsub("Acc", "Accelerometer", names(activityNames))
names(activityNames)<-gsub("Gyro", "Gyroscope", names(activityNames))
names(activityNames)<-gsub("BodyBody", "Body", names(activityNames))
names(activityNames)<-gsub("Mag", "Magnitude", names(activityNames))
names(activityNames)<-gsub("^t", "Time", names(activityNames))
names(activityNames)<-gsub("^f", "Frequency", names(activityNames))
names(activityNames)<-gsub("tBody", "TimeBody", names(activityNames))
names(activityNames)<-gsub("-mean()", "Mean", names(activityNames), ignore.case = TRUE)
names(activityNames)<-gsub("-std()", "STD", names(activityNames), ignore.case = TRUE)
names(activityNames)<-gsub("-freq()", "Frequency", names(activityNames), ignore.case = TRUE)
names(activityNames)<-gsub("angle", "Angle", names(activityNames))
names(activityNames)<-gsub("gravity", "Gravity", names(activityNames))

#******************************************************************
#Step 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#******************************************************************
library(dplyr);
finalTidyData <- activityNames %>%
  group_by(subjectId, activityId) %>%
  summarise_all(funs(mean))
  #aggregate(. ~subjectId + activityId, activityNames, mean)
finalTidyData <- finalTidyData[order(finalTidyData$subjectId, finalTidyData$activityId),]

#Writing tidy data set in file

write.table(finalTidyData, "finalTidyDataDCV.txt", row.name=FALSE)

