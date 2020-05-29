library(data.table)
library(dplyr)
library(rebus)

#loading available zip and pulling its relevant datasets

if(!file.exists("./Data")) {dir.create("./Data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, "./Data/HAR.zip", method = "curl")
unzip("./Data/HAR.zip", list = TRUE)

##reading in training datasets (3)
train_dat <- read.table("./Data/UCI HAR Dataset/train/X_train.txt", header = FALSE)
train_lab <- read.table("./Data/UCI HAR Dataset/train/y_train.txt", header = FALSE)
train_sub <- read.table("./Data/UCI HAR Dataset/train/subject_train.txt", header = FALSE)

##reading in test datasets (3)
test_dat <- read.table("./Data/UCI HAR Dataset/test/X_test.txt", header = FALSE)
test_lab <- read.table("./Data/UCI HAR Dataset/test/y_test.txt", header = FALSE)
test_sub <- read.table("./Data/UCI HAR Dataset/test/subject_test.txt", header = FALSE)

##reading in variable and acitivity names
features <- read.table("./Data/UCI HAR Dataset/features.txt", header = FALSE)
activities <- read.table("./Data/UCI HAR Dataset/activity_labels.txt", header = FALSE)

#Merging training and test sets to create one dataset

merged_df <- rbind(train_dat, test_dat)
merged_lab <- rbind(train_lab, test_lab)
merged_sub <- rbind(train_sub, test_sub)

colnames(merged_df) <- features$V2 ##labeling dataset w/ descriptive variable names
merged_df <- cbind(merged_df, Activity = merged_lab$V1, Subject_ID = merged_sub$V1)
colnames(merged_df) ##checking variable names of new, merged df

#Using descriptive activity names to name the activities in the data set

merged_df$Activity[] <- lapply(merged_df$Activity, function(x) activities$V2[match(x, activities$V1)])
merged_df$Activity <- unlist(merged_df$Activity)

#Extracting only the measurements on the mean and standard deviation for 
#each measurement & creating a second, independent tidy data set with the 
#average of each variable for each activity and each subject

colnames(merged_df) <- make.unique(colnames(merged_df)) ##renaming duplicate col names
literal("()") ##parentheses to stay as characters in regular expression use

clean_df <- merged_df %>% select(Subject_ID, Activity, everything()) %>%
    select(Subject_ID, Activity, matches("mean()|std()")) %>%
    group_by(Subject_ID, Activity) %>%
    summarise_all(funs(mean))

###exporting tidy data set as independent file
write.table(clean_df,"UCI-HAR-Data.txt", row.name = FALSE)

