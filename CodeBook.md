Code Book Overview
The “UCI-HAR-DATA” dataset is an independent tidy data set with the average of each variable for each activity and each subject based on data provided by the UCI HAR Dataset. Below is a description of the “UCI-HAR-DATA” variables, data, and transformations performed to clean the original files in the UCI HAR Dataset (source HERE).

“UCI-HAR-DATA” Variable Names & Data
The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix ‘t’ to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz.

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the ‘f’ to indicate frequency domain signals).

These signals were used to estimate variables of the feature vector for each pattern:
‘-XYZ’ is used to denote 3-axial signals in the X, Y and Z directions.

tBodyAcc-XYZ
tGravityAcc-XYZ
tBodyAccJerk-XYZ
tBodyGyro-XYZ
tBodyGyroJerk-XYZ
tBodyAccMag
tGravityAccMag
tBodyAccJerkMag
tBodyGyroMag
tBodyGyroJerkMag
fBodyAcc-XYZ
fBodyAccJerk-XYZ
fBodyGyro-XYZ
fBodyAccMag
fBodyAccJerkMag
fBodyGyroMag
fBodyGyroJerkMag
The set of variables that were estimated from these signals are:

mean(): Mean value
std(): Standard deviation
The additional set of variables that were estimated from the signals and also included in original UCI HAR Dataset features.txt are:

mad(): Median absolute deviation
max(): Largest value in array
min(): Smallest value in array
sma(): Signal magnitude area
energy(): Energy measure. Sum of the squares divided by the number of values.
iqr(): Interquartile range
entropy(): Signal entropy
arCoeff(): Autorregresion coefficients with Burg order equal to 4
correlation(): correlation coefficient between two signals
maxInds(): index of the frequency component with largest magnitude
meanFreq(): Weighted average of the frequency components to obtain a mean frequency
skewness(): skewness of the frequency domain signal
kurtosis(): kurtosis of the frequency domain signal
bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
angle(): Angle between to vectors.
Additional vectors obtained by averaging the signals in a signal window sample (in original UCI HAR Dataset but not tidy “UCI HAR DATA” .txt file. These are used on the angle() variable:

gravityMean
tBodyAccMean
tBodyAccJerkMean
tBodyGyroMean
tBodyGyroJerkMean
The complete list of these variables of each feature vector is available in ‘features.txt’

Variables were also included to specify subject id and tracked activity. These are:

Subject_ID
Activity
The complete list of Activity label values is available in ‘activity_labels.txt’

“run_analysis.R” Script
This R script was written in effort to reformat and clean the several .txt files included in the original UCI HAR Dataset, ultimately producing the tidy dataset “UCI-HAR-DATA” as described above.

“run_analysis.R” Environment
train_dat: Training dataset (X_train.txt)
train_lab: Training dataset labels (y_train.txt)
train_sub: Training dataset subject ID’s (subject_train.txt)
test_dat: Test dataset (X_test.txt)
test_lab: Test dataset labels (y_test.txt)
test_sub: Test dataset subject ID’s (subject_test.txt)
features: Features (descriptives of study measurements used for dataset variable names) (features.txt)
activities: Activity movements (reference against training and test labels) (activity_labels.txt)
merged_df: Dataframe with combined training and test datasets
merged_lab: Dataframe with combined training and test label datasets
merged_sub: Dataframe with combined training and test subject ID datasets
clean_df: Dataframe of all merged dataframes then subsetted to include only mean() & std() variables grouped by subjectID and activity
“run_analysis.R” Transformation Steps
All relevant datasets in UCI HAR Dataset(X_train.txt, y_train.txt, subject_train.txt, X_test.txt, y_test.txt, subject_test.txt, features.txt, activity_labels.txt) were downloaded and read into local environment as dataframes for easier data manipulation (see above environment objects for specification)

Training and test dataframes were clipped together via rbind (both dataframes had 561 variables but differing number of observations, thus rbind was utilized to avoid coercion). The training and test labels and the training and test subject ID dataframeswere also clipped together respectively in the same manner. This consolidated the available data, labels and subject ID’s for further manipulation.

The merged training and test data (merged_data dataframe) was then given appropriate column names according to the supplied features (now stored in the dataframe ‘features’). The descriptive variable names are found in column 2 (V2) of the features dataframe.

Now with the appropriate column names, the Acitivity and Subject_ID columns and their respective data were also added to the merged_data dataframe. Colnames were individually supplied while corresponding data was pulled from merged_lab (column 1 (V1), a vector of tracked activity via integer identification) and merged_sub (column 1 (V1), a list of all combined subject ID’s)

Integer identification of tracked activity in the now present “Activity” variable in the merged_data dataframe was updated to descriptive names via ‘activities’ dataframe reference. Specifically, each integer value in the Activity column was matched against ‘activities’ column 1 integers and replaced with the corresponding ‘activities’ column 2 descriptive activity name. lapply() was utilized to address each value in the Activity column individually with the supplied function(x). The resulting merged_df dataframe Activity column was then unlisted so levels were not listed in each independent value to keep simplisitic data available for any future analysis/manipulation

Because there are duplicate variable names as provided by the ‘features.txt’ file utilized as appropriate column names in the merged_df (duplicates refer the X, Y & Z axes but are not properly identified in the .txt file, the specification of X, Y or Z dropped altogether), make.unique() is used in order to identify each duplicate in a unique way to avoid variable name confusion. make.unique() appends a number according to each duplicate (ie, the first instance (X) will have no additional identifier but the second (Y) will have ‘.1’ appendage and the third (Z) will have ‘.2’ appendage). This is a quick way to create unique names to correctly distinguish variables without going through each of the 84 identified cases of variable duplicates individually.

Using dplyr piping, merged_df is first reordered so that Subject_ID and Activity columns are first in the dataframe. Next only the Subject_ID, Activity and variables with ‘mean()’ or ‘std()’ specifications are selected for the new dataframe (clean_df). ‘mean’ and ‘std’ were not selected as many of these specifications pull variables measuring vectors obtained by averaging the signals in a signal window sample rather than estimated mean or std of signals at a specific time-point and thus would provide inconsistent insight into aggregated mean and/or std values. Next, the new dataframe is piped into a group_by function so that mean() & std() related columns are grouped together according by first subject id and then by activity within the grouped id’s. Finally, with the grouped columns identified, the data is summarized via ‘mean’ function. The resulting data are the average values of each variable accross each subject’s specific activity. For example, each of Subject 1’s activities (ie, Walking, Sitting, etc.) should now have an average value per variable.

Resulting tidy, independent clean_df dataframe was exported as a .txt file as specified by course project instructions
