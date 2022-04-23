library(dplyr)

#We first assign a filename, download and unzip the dataset

filename <- 'Getting_and_Cleaning_data_Final_Project_Data.zip'
fileURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(fileURL, filename, method="curl")
unzip(filename) 

#We can then move on to assign the dataframes to variables we will work with

features <- read.table('UCI HAR Dataset/features.txt', col.names = c('n','functions'))
activities <- read.table('UCI HAR Dataset/activity_labels.txt', col.names = c('code', 'activity'))
subject_test <- read.table('UCI HAR Dataset/test/subject_test.txt', col.names = 'subject')
x_test <- read.table('UCI HAR Dataset/test/X_test.txt', col.names = features$functions)
y_test <- read.table('UCI HAR Dataset/test/y_test.txt', col.names = 'code')
subject_train <- read.table('UCI HAR Dataset/train/subject_train.txt', col.names = 'subject')
x_train <- read.table('UCI HAR Dataset/train/X_train.txt', col.names = features$functions)
y_train <- read.table('UCI HAR Dataset/train/y_train.txt', col.names = 'code')



#We can now move on to the actual cleaning part: 
#Step 1: Merge the training and the test sets to create one data set.
#We can simply use rbind() and cbind() to do that

X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
S <- rbind(subject_train, subject_test)
merge <- cbind(S, Y, X)


#Step 2: Extract only the measurements on the mean and standard deviation for each measurement.
#Also not a hard task, we can simply use the select() function.

clean_data <- merge %>% select(subject, code, contains('mean'), contains('std'))


#Step 3: Use descriptive activity names to name the activities in the data set.

clean_data$code <- activities[clean_data$code, 2]


#Step 4: Appropriately label the data set with descriptive variable names.
#Can be done using gsub() on our newly created clean_data

names(clean_data)[2] = "activity"
names(clean_data)<-gsub("Acc", "Accelerometer", names(clean_data))
names(clean_data)<-gsub("Gyro", "Gyroscope", names(clean_data))
names(clean_data)<-gsub("BodyBody", "Body", names(clean_data))
names(clean_data)<-gsub("Mag", "Magnitude", names(clean_data))
names(clean_data)<-gsub("^t", "Time", names(clean_data))
names(clean_data)<-gsub("^f", "Frequency", names(clean_data))
names(clean_data)<-gsub("tBody", "TimeBody", names(clean_data))
names(clean_data)<-gsub("-mean()", "Mean", names(clean_data), ignore.case = TRUE)
names(clean_data)<-gsub("-std()", "STD", names(clean_data), ignore.case = TRUE)
names(clean_data)<-gsub("-freq()", "Frequency", names(clean_data), ignore.case = TRUE)
names(clean_data)<-gsub("angle", "Angle", names(clean_data))
names(clean_data)<-gsub("gravity", "Gravity", names(clean_data))


#Step 5: From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

even_cleaner_data <- clean_data %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(even_cleaner_data, 'even_cleaner_data.txt', row.name=FALSE)


#Baby we done it! Now we can check the str() of our final dataset

str(even_cleaner_data)
