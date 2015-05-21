---
title: "Qualitative Activity Recognition of Weight Lifting Exercises"
output: html_document
---
This is my course project for the "Practical machine learning" MOOC at Coursera. 
<https://class.coursera.org/predmachlearn-014>

## Summary
Based on data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants I predict in which manner the study participants do a given weight lifting exercise. The data is taken from the study "Qualitative Activity Recognition of Weight Lifting Exercises" where participants were asked to perform barbell lifts correctly and incorrectly in 5 different ways. For more information see: <http://groupware.les.inf.puc-rio.br/har>

I expect my algorithm to predict activity quality with an out of sample error rate of about 1%. 

## Getting and cleaning the data

```r
library(caret)
```

Data source: <https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv>

```r
data <- read.csv("pml-training.csv")
```
The dataset contains 19622 observations of 160 variables. 152 of these variables are possible predictors since they contain data from accelerometers, but in many of them most of the cases are missing. 
Some examples: 

```
##  skewness_yaw_belt max_roll_belt     max_picth_belt   max_yaw_belt  
##         :19216     Min.   :-94.300   Min.   : 3.00          :19216  
##  #DIV/0!:  406     1st Qu.:-88.000   1st Qu.: 5.00   -1.1   :   30  
##                    Median : -5.100   Median :18.00   -1.4   :   29  
##                    Mean   : -6.667   Mean   :12.92   -1.2   :   26  
##                    3rd Qu.: 18.500   3rd Qu.:19.00   -0.9   :   24  
##                    Max.   :180.000   Max.   :30.00   -1.3   :   22  
##                    NA's   :19216     NA's   :19216   (Other):  275
```
In a first step I remove all those variables where the majority of cases contain no entries or NAs:

```r
nzCols <- nearZeroVar(data,saveMetrics=T)$nzv
naCols <- colMeans(is.na(data)) > 0.5
data <- data[,!(naCols | nzCols)]
```
## Split for cross validation
I split the data in a training set for model building and a testing set for cross validation.

```r
inTest <- createDataPartition(y=data$classe,p=0.7,list=F)
training <- data[inTest,]
testing <- data[-inTest,]
```

## Create model (include preprocessing)
Since this is a classifiation problem, the data ist abstract and the large number of variables makes it hard to select specific variables for prediction (and a simple classification tree didn't perform well in a first try) I'll
build the model using a random forest based on all complete cases of the accelerometer data variables. Centered and scaled.

```r
model <- train(data=training[7:59],classe ~.,method="rf",preProcess=c("center", "scale"))
```
The in sample accuracy of 0.9899038 looks promising.

## Prediction and cross validation
A prediction on the test data should verify the accuracy of the model and check for potential overfit.

```r
pred <- predict(model,newdata=testing) 
cm <- confusionMatrix(testing$classe,pred)
```
The confusion matrix shows an out of sample accuracy of 0.9908241

```
##           Reference
## Prediction    A    B    C    D    E
##          A 1673    1    0    0    0
##          B   10 1123    6    0    0
##          C    0   10 1015    1    0
##          D    0    0   20  943    1
##          E    0    0    0    5 1077
```

```
##       Accuracy  AccuracyLower  AccuracyUpper AccuracyPValue 
##      0.9908241      0.9880442      0.9930995      0.0000000
```
The estimated out of sample error is 0.0091759.
