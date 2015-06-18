setwd("./UCI HAR Dataset")
list.files(full.names=T,recursive=T)
library (dplyr)

# 1. Merges the training and the test sets to create one data set.
#    Load the files
subject_test<-read.table("./test/subject_test.txt")
subject_train<-read.table("./train/subject_train.txt")

x_test<-read.table("./test/X_test.txt")
x_train<-read.table("./train/X_train.txt")

y_test<-read.table("./test/y_test.txt")
y_train<-read.table("./train/y_train.txt")
#    Check the dimension
dim(subject_test); dim(subject_train)
dim(x_test); dim(x_train)
dim(y_test); dim(y_train)
#    Create the uniques datas and clear the previous data
subject_unique<-rbind(subject_test,subject_train); rm(subject_test); rm(subject_train)
x_unique<-rbind(x_test,x_train); rm(x_test); rm(x_train)
y_unique<-rbind(y_test,y_train); rm(y_test); rm(y_train)


# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#     Load the feature_vector
feature_vector<-read.table("features.txt")
dim(feature_vector)
#     I get the labels and apply them to my data
feature_vector<-feature_vector[[2]]
names(x_unique)<-feature_vector
#    I Extract the measures on the mean and standard deviation
mean_std<-grep("-mean|std()",feature_vector)
x_unique<-x_unique[,mean_std]
#    I check my new dimensions and remove useless variables
dim(x_unique); rm(mean_std); rm(feature_vector)


# 3. Uses descriptive activity names to name the activities in the data set
#    Load de activities names
activity_labels<-read.table("./activity_labels.txt")
names(activity_labels)<-c("activities","activity_names")
#    I create a data frame for activities and a column with the original order
y_unique<-data.frame(num=1:nrow(y_unique),activities=y_unique[[1]])
y_unique<-merge(y_unique,activity_labels,"activities",sort=FALSE)
rm(activity_labels)
#    not do sort in merge does not work in this case, then I go back to the original state
y_unique<-arrange(y_unique,num)
y_unique<-select(y_unique, -num, -activities)


#4. Appropriately labels the data set with descriptive variable names.
names(subject_unique)<-"subjects"
#   Create a unique data set with all the names
unique<-cbind(subject_unique,y_unique,x_unique)
#   Remove useless variables
rm(subject_unique); rm(x_unique); rm(y_unique)

#5. From the data set in step 4, creates a second, independent tidy data set 
#   with the average of each variable for each activity and each subject.
tidy<- aggregate(.~ subjects + activity_names, unique,mean)
#   write e file
write.table(tidy, file = "tidydata.txt",row.name=FALSE)
