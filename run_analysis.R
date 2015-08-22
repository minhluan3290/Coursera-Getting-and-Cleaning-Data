#Download and unzip data
#Create a folder in working directory named projectDataScience to house the downloaded the data

if(!file.exists("./projectDataScience")){dir.create("./projectDataScience")}

#Download data
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./projectDataScience/Dataset.zip",method="libcurl")

#Take a look at what included in the unzip folder UCI HAR Dataset by creating a list of file
file_dir <-file.path("./projectDataScience", "UCI HAR Dataset")
filelist <- list.files(file_dir, recursive = TRUE)
filelist

#Read tables and assign data to variables
#Read train and test tables of activity data
test_activitydata <-read.table(file.path(file_dir, "test" , "Y_test.txt" ),header = FALSE)
train_activitydata <- read.table(file.path(file_dir, "train", "Y_train.txt"),header = FALSE)

#Read train and test tables of subject data
train_subjectdata <- read.table(file.path(file_dir, "train", "subject_train.txt"),header = FALSE)
test_subjectdata  <- read.table(file.path(file_dir, "test" , "subject_test.txt"),header = FALSE)

#Read train and test tables of feature data
test_featuresdata  <- read.table(file.path(file_dir, "test" , "X_test.txt" ),header = FALSE)
train_featuresdata <- read.table(file.path(file_dir, "train", "X_train.txt"),header = FALSE)

# 1. Merges the training and the test sets to create one data set.

#Concatenate activity data tables using rbind and name the varibale
cdata_activity <- rbind(train_activitydata, test_activitydata)
names(cdata_activity)<- c("activity")

#Concatenate subject data tables using rbind and name the varibale
cdata_subject <- rbind(train_subjectdata, test_subjectdata)
names(cdata_subject) <-("subject")

#Concatenate feature data tables using rbind and name the varibale
cdata_features <- rbind(train_featuresdata, test_featuresdata)
names_datafeatures <- read.table(file.path(file_dir, "features.txt"),head=FALSE)
names(cdata_features)<- names_datafeatures$V2

#Merge combined data tables above to create a complete data frame
combinedDataTemp <- cbind(cdata_subject, cdata_activity)
FinalData <- cbind(cdata_features, combinedDataTemp)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#Subset the name of features by measurements, then subset data frame Final_Data by selected names of Features

subnames_datafeatures<-names_datafeatures$V2[grep("mean\\(\\)|std\\(\\)", names_datafeatures$V2)]
names_selected <-  c(as.character(subnames_datafeatures), "subject", "activity" )
FinalData<-subset(FinalData,select=names_selected)

# 3. Uses descriptive activity names to name the activities in the data set
# Read descriptive name from activity_labels.txt
label_activities <- read.table(file.path(file_dir, "activity_labels.txt"),header = FALSE)

# Factorize variable activity in the data frame FinalData using descriptive activity names read above.
FinalData$actifity<-factor(FinalData$activity)
FinalData$activity<- factor(FinalData$activity,labels=as.character(label_activities$V2))

# 4. Appropriately labels the data set with descriptive variable names
# Names of features will be labelled using descriptive label

names(FinalData)<-gsub("^t", "time", names(FinalData))
names(FinalData)<-gsub("^f", "frequency", names(FinalData))
names(FinalData)<-gsub("Acc", "Accelerometer", names(FinalData))
names(FinalData)<-gsub("Gyro", "Gyroscope", names(FinalData))
names(FinalData)<-gsub("Mag", "Magnitude", names(FinalData))
names(FinalData)<-gsub("BodyBody", "Body", names(FinalData))

# 5. Creates a second,independent tidy data set and ouput it

install.packages("plyr")
library(plyr)
FinalData2<-aggregate(. ~subject + activity, FinalData, mean)
FinalData2<-FinalData2[order(FinalData2$subject,FinalData2$activity),]
write.table(FinalData2, file = "tidydata.txt",row.name=FALSE)