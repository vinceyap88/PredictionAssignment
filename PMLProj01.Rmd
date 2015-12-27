---
title: "Building Manner Prediction Model of Weight Lifting Exercises"
author: "Yap Koon Hoe"
date: "December 24, 2015"
output: html_document
---

## Synopsis
In this report we aim to predict the manner applied in weight lifting exercises(WLE). The devices such as Jawbone Up, Nike FuelBand, and Fitbit are part of the quantified self movement tested on a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patters in their behavior, or because they are tech geeks. The measurements are taken from the accelerometers on the belt, forearm, arm, and dumbell of the 6 pariticipants performing the barbell lifts correctly and incrrectly in 5 different ways.

## Data Processing
From the [Human Activity Recognition Research ](http://groupware.les.inf.puc-rio.br/har), it has described the WLE dataset which can be downloaded as below:

    a. [Training data](https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv)
    b. [Test data](https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv)
    
We read in the WLE dataset from the raw text file stored in csv format where fields are delimited with the comma. By examining the dataset, there are some missing values appeared as empty, NA as well as "#DIV/0!".
```{r cache=TRUE}
wleTrainUrl <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
wleTrainFile<- "pml-training.csv"
download.file(wleTrainUrl,destfile=wleTrainFile,method="curl")
wleTrainRaw<-read.csv(wleTrainFile, sep = ",", na.strings = c("","NA","#DIV/0!"))

wleTestUrl <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
wleTestFile<- "pml-testing.csv"
download.file(wleTestUrl,destfile=wleTestFile,method="curl")
wleTestRaw<-read.csv(wleTestFile, sep = ",", na.strings = c("","NA","#DIV/0!"))
```

Each dataset contains 160 columns and 19622 rows.
```{r}
dim(wleTrainRaw)
dim(wleTestRaw)
```
## Data Cleaning
Remove the X, user_name, raw_timestamp_part_1, raw_time_part_2, cvtd_timestamp, new_window and num_window columns. 
```{r}
wleTrainRaw<-wleTrainRaw[,-c(1:7)]
```
After removing the columns which contains more than 70% of missing values, the testing set reduced to 53 columns.
```{r}
wleTrainRaw<-wleTrainRaw[,colSums(is.na(wleTrainRaw))<.7*nrow(wleTrainRaw)]
dim(wleTrainRaw)
```
Select the same column names for training set following the testing set These testing set will be used for cross validation.
```{r}
wleValidate<-wleTestRaw[,c(colnames(wleTrainRaw)[1:52],'problem_id')]
dim(wleValidate)
```
##Data Slicing
Since the training set is large, it will be divided as 75% observations for training subset and the remaining as test subset. For reproducibility purposes, the seed is setto 1221. 
```{r warning=FALSE, message=FALSE}
library(caret)
set.seed(1221)
wleTrainDP<-createDataPartition(y=wleTrainRaw$classe, p=0.75, list=FALSE)
wleTrainSS<-wleTrainRaw[wleTrainDP,]
wleTestSS<-wleTrainRaw[-wleTrainDP,]
rbind("Training subset"=dim(wleTrainSS), "Test subset"=dim(wleTestSS))
```
##Checking Zero Covariates
There are no zero variance predictors or near-zero variance predictors exist, thus no predictors will be removed in the construction of the prediction model.
```{r}
nzv<-nearZeroVar(wleTrainSS, saveMetrics=TRUE)
str(nzv, vec.len=2)
nzv[nzv[,"zeroVar"]+nzv[,"nzv"]>0,]
```
##Building Model With Classification Tree
The result showed that the 4 preditors of this model are roll_belt, pitch_forearm, magnet_dumbbell_y and roll_forearm variables. It has taken approximately 15 seconds to build this model but with the poor accuracy(0.4488).
```{r}
time1<-proc.time()
ctreeFit<-train(classe~.,method="rpart",data=wleTrainSS)
time2<-proc.time()
ctreeTime<-time2-time1
#the duration used for building the model
ctreeTime
print(ctreeFit$finalModel)
rattle::fancyRpartPlot(ctreeFit$finalModel)
```
#Cross-Validation With Classification Tree Model
```{r}
confusionMatrix(wleTestSS$classe, predict(ctreeFit, wleTestSS))
```
##Building Model With Random Forest
The result showed that it has taken approximately 40 seconds to build this model but with the higher accuracy(0.9947).
```{r}
library(randomForest)
time1<-proc.time()
rforestFit<-randomForest(classe~.,data=wleTrainSS, importance=TRUE)
time2<-proc.time()
rforestTime<-time2-time1
#the duration used for building the model
rforestTime
# return the first 6 rows of the second tree
head(getTree(rforestFit,k=2))
# list out the variable importance
varImpPlot(rforestFit)
```
#Cross-Validation With Random Forest Model
```{r}
result=predict(rforestFit, wleTestSS)
cm<-confusionMatrix(wleTestSS$classe, result)
```

##Expected Out-Of-Sample Error and Estimated Sample Error
The expected out-of-sample error is 0.005301794, as well as the estimated sample error is 0.005301794.
```{r}
#Expected Out-Of-Sample Error
expOutOfSampleError<-1-cm$overall['Accuracy'] 
names(expOutOfSampleError)<-"Expected Out-Of-Sample Error"
expOutOfSampleError
#Estimated Sample Error
estSampleError<-1-(sum(result==wleTestSS$classe)/length(result))
estSampleError
```
##Choosing the Final Model for the Prediction
Considering the high accuracy and the small sample error by ignoring the speed factor, I have decided to use the Random Forest Model to perform the prediction on the testing set.
```{r}
testingPred<-predict(rforestFit, wleValidate)
testingPred
```
##Generate Prediction Output
```{r}
## Seed is set to 1221 to produce this results.
answer<-as.character(testingPred)
pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}
pml_write_files(answer)
```

##Conclusion
I have been convinced that using this Random Forest Model with the high accuracy and small error rate can be used to predict the manner executed in weight lifting exercises. 
